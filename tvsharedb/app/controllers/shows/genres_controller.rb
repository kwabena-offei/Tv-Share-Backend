require 'set'

class Shows::GenresController < ActionController::Base
  PAGE_SIZE = 25
#  caches_action :index, expires_in: 5.minutes, if: -> { Rails.env.production? }

  # all genres each with the first PAGE_SIZE shows
  def index
    # only show a show once per genre
    used_tms_ids = Set.new
    @station_id = params[:station_id]
    @genre_shows = GenreMap.to_h.reduce({}) do |memo, (title, subgenres)|
      shows = Show.with_tms_id.non_episode
        .where.not(tmsId: used_tms_ids)
        .select(:id, :title, :genres, :preferred_image_uri, :tmsId, :seriesId, :rootId, :popularity_score)
        .by_genres(subgenres)
        .order(:popularity_score)
        .yield_self do |show|
          if params[:station_id].blank?
            show.joins(:networks)
          elsif params[:station_id].to_i.zero? # string, not an integer
            show.where(original_streaming_network: params[:station_id])
          else
            show.joins(:networks).where(networks: { station_id: params[:station_id] })
          end
        end
        .distinct
        .page(1)
        .per(PAGE_SIZE)

        shows.each { |show| used_tms_ids.add(show.tmsId) }
        memo[title] = shows
      memo
    end
  end

  def show
    @station_id = params[:station_id]
    @genre = params[:genre]
    sub_genres = GenreMap.to_h[@genre]
    @shows = Show.with_tms_id.non_episode
      .select(:id, :title, :genres, :preferred_image_uri, :tmsId, :seriesId, :rootId, :popularity_score)
      .by_genres(sub_genres)
      .order(:popularity_score)
      .yield_self do |show|
        if params[:station_id].blank?
          show.joins(:networks)
        elsif params[:station_id].to_i.zero? # string, not an integer
          show.where(original_streaming_network: params[:station_id])
        else
          show.joins(:networks).where(networks: { station_id: params[:station_id] })
        end
      end
      .distinct
      .page(params[:page])
      .per(PAGE_SIZE)
  end
end
