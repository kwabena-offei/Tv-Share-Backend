desc "Import new shows via Gracenote live guide"
task import_shows_via_live_guide: :environment do
  puts "Importing shows via live guide..."
  ImportLiveGuideJob.perform_now
  puts "Finished importing shows."
end

desc "Import original shows"
task import_original_shows: :environment do
  puts "Importing Netflix Originals..."
  ImportNetflixOriginalsJob.perform_now

  puts "Importing Hulu Originals..."
  ImportHuluOriginalsJob.perform_now

  puts "Finished importing originals."
end

desc "Update existing shows"
task update_shows: :environment do
  puts "Updating existing shows..."

  Show.with_tms_id.order(updated_at: :asc).limit(500).find_each do |show|
    ImportShowJob.perform_now(tms_id: show.tmsId)
  end

  puts "Finished updating existing shows."
end
