class Admin::MatchingController < AdminController
  def index
  end

  def shows
    data = Show.where.not(original_streaming_network: nil).order(:title).map do |show|
      show.as_json.reject! {|k,v| ['created_at', 'updated_at'].include?(k) || v.blank? }
    end

    render json: data
  end

  def possible_matches
    api_url = "http://data.tmsapi.com/v1.1/programs/search?q=#{params[:title]}&queryFields=title&titleLang=en&descriptionLang=en&api_key=#{ENV['TMS_API_KEY']}"
    api_response = HTTParty.get(api_url)
    render json: api_response['hits']
  end
end
