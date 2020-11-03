class ImportNetworkShowsJob < ApplicationJob
  queue_as :default

  def perform(network)
    import_network_shows(network)
  end

  def import_network_shows(network)
    get_station_airings(network).each do |airing|
      show = Show.includes(:networks).find_or_import_by_tms_id(airing['program']['tmsId'])

      next unless show.present?
      show.networks << network unless show.networks.include?(network)
    end
  end

  def get_station_airings(network)
    response = HTTParty.get api_url(network.station_id)
    JSON.parse(response.body)
  end

  private

  def api_url(station_id)
    "http://data.tmsapi.com/v1.1/stations/#{station_id}/airings?startDateTime=#{7.days.ago.iso8601}&endDateTime=#{14.days.from_now.iso8601}&api_key=#{ENV['TMS_API_KEY']}"
  end
end
