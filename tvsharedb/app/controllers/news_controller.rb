class NewsController < ActionController::Base
  def index
    @stories = Story.includes(:story_source).order(published_at: :desc).limit(50)
  end
end
