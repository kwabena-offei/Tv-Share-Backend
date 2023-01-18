class ProxyController < ApplicationController
  def show
    gracenote_api_client = GracenoteApi.new(requested_by: self.class)
    api_path = request.fullpath.split('data/').last
    api_url = "https://data.tmsapi.com/#{api_path}&api_key=#{ENV['TMS_API_KEY']}"
    render json: gracenote_api_client.get(api_url)
  end
end