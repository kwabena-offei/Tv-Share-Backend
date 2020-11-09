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
      station_id = result['stationId']
      result['airings'].each do |airing|
        program = airing['program']
        import_show_or_parent(program, station_id)
      end
    end
  end

  def import_show_or_parent(program, station_id)
    import_show(program, station_id)

    if program['tmsId'].start_with?('EP')
      # We have an episode, we need to request parent series data
      show = Show.includes(:networks).find_by(seriesId: program['seriesId'])
      if show.present?
        # the show is already in our db, so ensure it is associated with this network
        assign_network(show, station_id)
      else
        # the show is not in our db, do a full import
        data = get_parent_show_data(program)
        import_show(data, station_id)
      end
    end
  end

  def import_show(program, station_id)
    show = Show.find_or_import_by_tms_id(program['tmsId'])
    assign_network(show, station_id) if show.present?
  end

  def assign_network(show, station_id)
    unless show.networks.pluck(:station_id).include?(station_id)
      network = Network.find_by(station_id: station_id)
      if network.present?
        show.networks << network
        show.save
      end
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
