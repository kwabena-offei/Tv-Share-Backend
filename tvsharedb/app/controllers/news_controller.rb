class NewsController < ActionController::Base
  caches_action :index, expires_in: 10.minutes

  def index
    @stories = Story.order(published_at: :desc).first(50)
  end
end
