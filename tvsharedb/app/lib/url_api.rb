class UrlApi
  include HTTParty
  def self.fetch start_date, end_date, networks
    api_url = "https://data.tmsapi.com/v1.1/lineups/USA-HULU501-DEFAULT/grid?startDateTime=#{start_date}&endDateTime=#{end_date}&stationId=#{networks.map{|network| network[:stationId]}}&imageAspectTV=4x3&imageSize=Lg&api_key=#{ENV['TMS_API_KEY']}"
    resp = HTTParty.get(api_url)
    resp.body
  end
end
