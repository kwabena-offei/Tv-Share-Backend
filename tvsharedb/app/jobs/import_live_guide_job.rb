# Calls the Gracenote API for shows airing in the next X hours
# and imports any show that is not yet in our DB
class ImportLiveGuideJob < ApplicationJob
  queue_as :default

  def perform(*args)
    if ENV['TMS_API_KEY'].blank?
      raise 'TMS_API_KEY not found, can not import live guide'
    end

    api_response = HTTParty.get(api_url)

    api_response.each do |result|
      network_name = result['affiliateCallSign'] || result['callSign']
      result['airings'].each do |airing|
        program = airing['program']
        import_show_or_parent(program, network_name)
      end
    end
  end

  def import_show_or_parent(program, network_name)
    if program['tmsId'].match(/^(SH|MV).*/)
      # We have a root show or movie, import as-is
      import_show(program, network_name)
    else
      # We have an episode, we need to request parent series data
      show = Show.includes(:networks).find_by(seriesId: program['seriesId'])
      if show.present?
        # the show is already in our db, so ensure it is associated with this network
        assign_network(show, network_name)
      else
        # the show is not in our db, do a full import
        data = get_parent_show_data(program)
        import_show(data, network_name)
      end
    end
  end

  def import_show(program, network_name)
    show = Show.includes(:networks).find_or_initialize_by(tmsId: program['tmsId'])
    show.update({
      rootId: program['rootId'],
      seriesId: program['seriesId'],
      subType: program['subType'],
      title: program['title'],
      releaseYear: program['releaseYear'],
      releaseDate: program['releaseDate'],
      origAirDate: program['origAirDate'],
      titleLang: program['titleLang'],
      descriptionLang: program['descriptionLang'],
      entityType: program['entityType'],
      genres: program['genres'],
      longDescription: program['longDescription'],
      shortDescription: program['shortDescription'],
      runTime: program['runTime'],
      preferred_image_uri: program.dig('preferredImage', 'uri')
    })

    assign_network(show, network_name)
  end

  def assign_network(show, network_name)
    unless show.networks.pluck(:name).include?(network_name)
      network = Network.find_or_initialize_by(name: network_name)
      show.networks << network
      show.save
    end
  end

  def get_parent_show_data(program)
    url = "https://data.tmsapi.com/v1.1/programs/#{program['seriesId']}?api_key=#{ENV['TMS_API_KEY']}"
    HTTParty.get(url)
  end

  def api_url
    # rounds the current time down the the latest 30 minute increment
    timestamp = Time.at(Time.now.to_i - (Time.now.to_i % 30.minutes)).iso8601
    "https://data.tmsapi.com/v1.1/lineups/USA-HULU501-DEFAULT/grid?startDateTime=#{timestamp}&api_key=#{ENV['TMS_API_KEY']}";
  end
end
