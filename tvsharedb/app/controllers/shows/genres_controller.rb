class Shows::GenresController < ActionController::Base
  PAGE_SIZE = 25
  caches_action :index, expires_in: 5.minutes, if: -> { Rails.env.production? }

  # all genres each with the first PAGE_SIZE shows
  def index
    @genre_shows = GenreMap.to_h.reduce({}) do |memo, (title, subgenres)|
      memo[title] = Show.with_tms_id.non_episode
        .select(:id, :title, :preferred_image_uri, :tmsId, :seriesId, :rootId)
        .by_genres(subgenres)
        .order(:title)
        .page(1)
        .per(PAGE_SIZE)
      memo
    end
  end

  def show
    @genre = params[:genre]
    sub_genres = GenreMap.to_h[@genre]
    @shows = data = Show.with_tms_id.non_episode.by_genres(sub_genres).order(:title).page(params[:page]).per(PAGE_SIZE)
  end
end
