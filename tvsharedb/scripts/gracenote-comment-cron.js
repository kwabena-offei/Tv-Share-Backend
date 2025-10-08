// Script to fetch episode metadata from GraceNote and post bot comments
// Requires environment variables:
//  - MONGODB_URI: MongoDB connection string
//  - TMS_API_KEY: API key for the GraceNote metadata service
//    (GRACENOTE_API_KEY is also supported for backward compatibility)
//  - BOT_USER_ID: identifier of the bot user for comments
//
// The script is designed to be run periodically via a cron job or Heroku
// scheduler. It connects to MongoDB, finds episodes without a bot comment, pulls
// metadata from GraceNote, and adds the description as a comment.

const { MongoClient, ObjectId } = require('mongodb');
const cron = require('node-cron');
const fetch = require('node-fetch');

const mongoUrl = process.env.MONGODB_URI;
const apiKey = process.env.TMS_API_KEY || process.env.GRACENOTE_API_KEY;
const botUserId = process.env.BOT_USER_ID;

if (!mongoUrl || !apiKey || !botUserId) {
  console.error('Missing environment configuration. Ensure MONGODB_URI, BOT_USER_ID and TMS_API_KEY or GRACENOTE_API_KEY are set.');
  process.exit(1);
}

async function fetchEpisodeMetadata(externalId) {
  // TODO: Implement actual call to GraceNote API using externalId
  // Example placeholder using fetch:
  const url = `https://data.tmsapi.com/v1.1/series/${externalId}?api_key=${apiKey}`;
  try {
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`GraceNote request failed: ${response.status}`);
    }
    return await response.json();
  } catch (err) {
    console.error('Failed to fetch GraceNote metadata', err);
    return null;
  }
}

async function postBotComments(db) {
  const episodes = db.collection('episodes');
  const comments = db.collection('comments');

  // Find episodes that do not yet have a comment from the bot
  const cursor = episodes.find({ botCommented: { $ne: true } });

  while (await cursor.hasNext()) {
    const episode = await cursor.next();
    const metadata = await fetchEpisodeMetadata(episode.externalId);
    if (!metadata || !metadata.description) continue;

    const comment = {
      episodeId: episode._id,
      userId: ObjectId(botUserId),
      body: metadata.description,
      createdAt: new Date(),
    };
    await comments.insertOne(comment);
    // Mark episode as having received a bot comment
    await episodes.updateOne({ _id: episode._id }, { $set: { botCommented: true } });
    console.log(`Posted bot comment for episode ${episode._id}`);
  }
}

async function runJob() {
  const client = new MongoClient(mongoUrl, { useUnifiedTopology: true });
  try {
    await client.connect();
    const db = client.db();
    await postBotComments(db);
  } catch (err) {
    console.error('Error running comment job', err);
  } finally {
    await client.close();
  }
}

// Run daily at 3 AM UTC
cron.schedule('0 3 * * *', () => {
  console.log('Running GraceNote comment bot job...');
  runJob().catch(err => console.error(err));
});

// If the script is executed directly, run once immediately
if (require.main === module) {
  runJob().catch(err => console.error(err));
}
