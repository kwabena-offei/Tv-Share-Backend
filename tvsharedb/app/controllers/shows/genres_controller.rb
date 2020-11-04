class Shows::GenresController < ActionController::Base
  PAGE_SIZE = 25
#  caches_action :index, expires_in: 5.minutes, if: -> { Rails.env.production? }

  # all genres each with the first PAGE_SIZE shows
  def index
    @genre_shows = GenreMap.to_h.reduce({}) do |memo, (title, subgenres)|
      memo[title] = Show.with_tms_id.non_episode
        .select(:id, :title, :preferred_image_uri, :tmsId, :seriesId, :rootId)
        .by_genres(subgenres)
        .order(:popularity_score)
        .yield_self do |show|
          if params[:station_id].blank?
            show
          elsif params[:station_id].to_i.zero? # string, not an integer
            show.where(original_streaming_network: params[:station_id])
          else
            show.joins(:networks).where(networks: { station_id: params[:station_id] })
          end
        end
        .page(1)
        .per(PAGE_SIZE)
      memo
    end
  end

  def show
    @genre = params[:genre]
    sub_genres = GenreMap.to_h[@genre]
    @shows = Show.with_tms_id.non_episode
      .by_genres(sub_genres)
      .order(:popularity_score)
      .yield_self do |show|
        if params[:station_id].blank?
          show
        elsif params[:station_id].to_i.zero? # string, not an integer
          show.where(original_streaming_network: params[:station_id])
        else
          show.joins(:networks).where(networks: { station_id: params[:station_id] })
        end
      end
      .page(params[:page])
      .per(PAGE_SIZE)
  end
end
