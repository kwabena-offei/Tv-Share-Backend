require 'set'

class Shows::GenresController < ActionController::Base
  PAGE_SIZE = 25
  caches_action :index, expires_in: 7.days, cache_path: -> { cache_keys }
  caches_action :show, expires_in: 7.days, cache_path: -> { cache_keys }
  caches_action :live, expires_in: 5.minutes


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

  def live
    # This station list is static, but could be drived from Networks::LIST
    station_ids = '16689,20459,20453,20373,20360,19548,32026,61469,34941,42642,63236,58515,58452,32645,60048,11006,60179,58646,58625,45507,43362,58623,51529,74550,64241,58574,59337,73541,60150,56905,57391,60046,59440,64490,60964,26182,59186,49788,70388,59250,60696,48639,59684,67331,70522,59444,35402,46275,82547,61812,65732'
    response = HTTParty.get("https://data.tmsapi.com/v1.1/lineups/USA-HULU501-DEFAULT/grid?startDateTime=&endDateTime=#{4.hours.from_now.iso8601}&stationId=#{station_ids}&imageAspectTV=4x3&imageSize=Md&imageText=true&api_key=#{ENV['TMS_API_KEY']}")

    # Removing paid programming from response
    live_data = JSON.parse(response.body).flat_map do |station|
      station['airings'] = station['airings'].map do |airing|
        if airing['program']['subType'] != 'Paid Programming'
          airing
        else
          nil
        end
      end.compact
      station
    end

    render json: live_data
  end


  # Allows for dynamic caching
  def cache_keys
    { station_id: request.params[:station_id], genre: request.params[:genre], page: request.params[:page] }
  end
end
