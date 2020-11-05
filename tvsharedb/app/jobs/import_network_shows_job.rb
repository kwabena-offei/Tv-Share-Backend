require 'set'

class ImportNetworkShowsJob < ApplicationJob
  attr_accessor :network, :series_ids, :non_series_tms_ids
  queue_as :default

  def perform(network)
    @network = network
    @series_ids = Set.new
    @non_series_tms_ids = Set.new
    import_network_shows
  end

  def import_network_shows
    get_station_program_data
    import_series
    import_non_series
  end

  def import_series
    @series_ids.each do |series_id|
      Show.includes(:networks).where(seriesId: series_id).find_each do |_show|
        _show.networks << network unless _show.networks.include?(network)
      end
    end
  end

  def import_non_series
    @non_series_tms_ids.each do |tms_id|
      show = Show.includes(:networks).find_or_import_by_tms_id(tms_id)
      next if show.blank?
      show.networks << network unless show.networks.include?(network)
    end
  end

  private

  def get_station_data
    response = HTTParty.get api_url(@network.station_id)
    JSON.parse(response.body)
  end

  def get_station_program_data
    get_station_data.reduce({}) do |memo, airing|
      program = airing['program']
      series_id = program['seriesId']
      tms_id = program['tmsId']

      if series_id
        @series_ids.add(series_id)
      else
        @non_series_tms_ids.add(tms_id)
      end
    end
  end

  def api_url(station_id)
    "http://data.tmsapi.com/v1.1/stations/#{station_id}/airings?startDateTime=#{7.days.ago.iso8601}&endDateTime=#{14.days.from_now.iso8601}&api_key=#{ENV['TMS_API_KEY']}"
  end
end
