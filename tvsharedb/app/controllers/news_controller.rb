class NewsController < ActionController::Base
  caches_action :index, expires_in: 10.minutes

  def index
    response = HTTParty.get('https://api.cognitive.microsoft.com/bing/v7.0/news?category=Entertainment_MovieAndTV', headers: {
      'Ocp-Apim-Subscription-Key' => ENV['BING_API_KEY']
      })
    render json: response.body
  end
end
