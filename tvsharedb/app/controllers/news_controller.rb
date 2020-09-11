class NewsController < ActionController::Base
  def index
    @stories = Story.order(published_at: :desc).limit(50)
  end
end
