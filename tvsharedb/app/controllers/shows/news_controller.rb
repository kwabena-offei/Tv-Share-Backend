class Shows::NewsController < ActionController::Base
  caches_action :index, expires_in: 10.minutes, cache_path: -> { request.params[:id] }

  def index
    @show = get_show
    ImportShowNewsJob.perform_now(@show)
    @stories = @show.stories
    render template: 'news/index'
  end

  private

  def get_show
    show = Show.find_by(tmsId: params[:id])
    if show.blank?
      ImportShowJob.perform_now(tmsId: params[:id])
      show = Show.find_by(tmsId: params[:id])
    end
    show
  end

end
