desc "Import new shows via Gracenote live guide"
task import_shows_via_live_guide: :environment do
  puts "Importing shows via live guide..."
  ImportLiveGuideJob.perform_now
  puts "Finished importing shows."
end
