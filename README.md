# Tv-Share-Backend

[API Docs](https://github.com/kwabena-offei/Tv-Share-Backend/blob/master/tvsharedb/README-API.md)

[Websockets Docs](https://github.com/kwabena-offei/Tv-Share-Backend/blob/master/tvsharedb/README-WEBSOCKETS.md)

## Environment Variables

Copy `tvsharedb/env.example` to `.env` and fill in your credentials. These
variables are loaded via [dotenv](https://github.com/bkeepers/dotenv).

Required variables:

```
REDIS_URL=redis://localhost
BING_API_KEY=your_key
CLOUDINARY_URL=
GOOGLE_AUTH_CLIENT_ID=
TMS_API_KEY=
FRONT_END_URL=http://localhost:3000
API_HOST=https://tvchat-api.herokuapp.com
NEWS_API_HOST=https://tvchat-news-search.herokuapp.com
```

## Local Setup

__Setup your database:__ `bundle exec rake db:setup`
This should create the database, run the migrations, and seed the database with a list of networks.

__Import shows into your database:__
- Open a rails console: `bundle exec rails console`
- Start the `ImportLiveGuideJob.perform_now`
- This will start importing shows that are currently airing on TV. Let this run for a couple of minutes and then feel free to stop it (by pressing `ctrl+c`)

You should now have a number of Networks and real shows in your database.

## Scheduled Tasks

Several maintenance tasks are defined in
`tvsharedb/lib/tasks/scheduler.rake`. They can be run manually or added to a
[Heroku Scheduler](https://devcenter.heroku.com/articles/scheduler) job. Common
tasks include:

```
bundle exec rake update_top_commenters
bundle exec rake update_top_comments
bundle exec rake update_search
```

Run these periodically to keep indexes and statistics up to date.
