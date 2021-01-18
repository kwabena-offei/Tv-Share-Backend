require 'set'

class Shows::GenresController < ActionController::Base
  PAGE_SIZE = 25
  caches_action :index, expires_in: 7.days, cache_path: -> { cache_keys }, if: -> { Rails.env.production? }
  caches_action :show, expires_in: 7.days, cache_path: -> { cache_keys }, if: -> { Rails.env.production? }
  caches_action :live, expires_in: 14.minutes, if: -> { Rails.env.production? }


  # all genres each with the first PAGE_SIZE shows
  def index
    # only show a show once per genre
    used_tms_ids = Set.new
    @station_id = params[:station_id]
    @genre_shows = GenreMap.to_h.reduce({}) do |memo, (title, subgenres)|
      shows = Show.parent_shows
        .where.not(tmsId: used_tms_ids)
        .select(:id, :title, :genres, :preferred_image_uri, :tmsId, :seriesId, :rootId, :popularity_score)
        .by_genres(subgenres)
        .order(popularity_score: :desc)
        .yield_self do |show|
          if params[:station_id].blank?
            show.joins(:networks)
          elsif params[:station_id].to_i.zero? # string, not an integer
            show.where(original_streaming_network: params[:station_id]&.downcase)
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
    @shows = Show.select(:id, :title, :genres, :preferred_image_uri, :tmsId, :seriesId, :rootId, :popularity_score)
      .by_genres(sub_genres)
      .order(popularity_score: :desc)
      .yield_self do |show|
        if params[:station_id].blank?
          show.parent_shows.joins(:networks)
        elsif params[:station_id].to_i.zero? # string, not an integer
          show.non_episode.where(original_streaming_network: params[:station_id])
        else
          show.parent_shows.joins(:networks).where(networks: { station_id: params[:station_id] })
        end
      end
      .distinct
      .page(params[:page])
      .per(PAGE_SIZE)
  end

  ## This will return a list of stations
  ## Each station will have a list of airings (shows)
  ## We need to query our DB to get the "popularity_score", and we should sort based on that data.
  def live
    url = get_live_api_url
    response = HTTParty.get(url)
    show_map = { tmsIds: [] }
    # Removing paid programming from response
    live_data = JSON.parse(response.body).flat_map do |station|
      station['airings'] = station['airings'].map do |airing|
        show_airing = airing['program']
        # Filter out paid programs
        if show_airing['subType'] != 'Paid Programming'
          show_map[:tmsIds].push(show_airing['tmsId'])
          airing
        else
          nil
        end
      end.compact
      station
    end

    shows = Show.includes(:parent_program).where(tmsId: show_map[:tmsIds]).order('popularity_score DESC').each_with_object({tmsIds: {}}).each do |show, db_show_map|
      db_show_map[:tmsIds][show.tmsId] = show
    end

    missing_series = []
    live_data = live_data.map do |data|
      data['airings'] = data['airings'].map do |airing|
        show_airing = airing['program']
        program = shows[:tmsIds][show_airing['tmsId']]
        if program&.preferred_image_uri
          airing['program']['preferredImage'] = { 'uri' => program.preferred_image_uri }
        end
        airing['program']['popularity_score'] = program&.parent_program&.popularity_score || program&.popularity_score
        airing
      end

      data
    end#.sort_by { |station| Time.parse(station['airings'][0]['startTime']) }

    render json: live_data
  end

  def upcoming
  end

  # need to send endDateTime to front end, and then use that as startDateTime for the next batch of pagination
  def get_live_api_url
    # if viewing a specific station
    if params[:station_id].present?
      # rounds the current time down the the latest 30 minute increment
      start_time = Time.at(Time.now.to_i - (Time.now.to_i % 30.minutes))
      end_time = (start_time + 14.days)
      station_ids = params[:station_id]
      url = "https://data.tmsapi.com/v1.1/lineups/USA-HULU501-DEFAULT/grid?startDateTime=#{start_time.iso8601}&endDateTime=#{end_time.iso8601}&stationId=#{station_ids}&imageAspectTV=4x3&imageSize=Md&imageText=true&api_key=#{ENV['TMS_API_KEY']}"
    else
      # rounds the current time down the the latest 30 minute increment
      start_time = Time.at(Time.now.to_i - (Time.now.to_i % 30.minutes))
      end_time = (start_time + 14.days)
      station_ids = Networks::LIST.map { |n| n[:stationId] }.join(',')
      url = "https://data.tmsapi.com/v1.1/lineups/USA-HULU501-DEFAULT/grid?startDateTime=#{start_time.iso8601}&endDateTime=#{end_time.iso8601}&stationId=#{station_ids}&imageAspectTV=4x3&imageSize=Md&imageText=true&api_key=#{ENV['TMS_API_KEY']}"
    end
  end

  # Allows for dynamic caching
  def cache_keys
    { station_id: request.params[:station_id], genre: request.params[:genre], page: request.params[:page] }
  end
end
