class ImportNetflixOriginalsJob < ApplicationJob
  URL = 'https://media.netflix.com/gateway/v1/en/titles'
  queue_as :default

  def perform(*args)
    api_response = HTTParty.get(URL)
    api_response['items'].each do |program|
      import_show(program)
    end
  end

  def import_show(program)
    release_date = get_release_date(program['premiereDate'])

    Show.create({
      original_streaming_network: :netflix,
      original_streaming_network_id: program['id'],
      title: program['name'],
      entityType: program['type'],
      releaseDate: release_date,
      releaseYear: release_date&.year
    })
  end

  # Sometimes Netflix gives us "Upcoming" or "2020" as the release date.
  # This will return nil in those instances.
  def get_release_date(release_date)
    Date.parse(release_date)
  rescue ArgumentError
    nil
  end
end
