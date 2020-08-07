class Shows::GenresController < ActionController::Base
  PAGE_SIZE = 25000
  caches_action :index, expires_in: 1.hour

  # all genres each with the first 25 shows
  def index
    data = GenreMap.to_h.reduce({}) do |memo, (title, subgenres)|
      memo[title] = Show.with_tms_id.non_episode.by_genres(subgenres).order(:title).limit(PAGE_SIZE)
      memo
    end

    render json: data
  end

  def show
    @genre = params[:genre]
    sub_genres = GenreMap.to_h[params[:genre]]
    @shows = data = Show.with_tms_id.non_episode.by_genres(sub_genres).order(:title).page(params[:page]).limit(PAGE_SIZE)
  end
end
