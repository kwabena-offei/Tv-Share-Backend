class LineupCache
  PAGE_SIZE = 25
  EXPIRATION_DAYS = 7

  def initialize(start_time: nil, station_id: nil)
    @start_time = start_time&.to_time || Time.current
    @station_id = station_id
    @lineup = 'USA-HULU501-DEFAULT'
  end

  def cache(clear_cache: false)
    Rails.cache.fetch("lineup_#{@lineup}", expires_in: EXPIRATION_DAYS.days, force: clear_cache) do
      live
    end
  end

  def live
    response = HTTParty.get(get_lineup_api_url)
    live_data = JSON.parse(response.body)
    tms_ids = extract_tms_ids(live_data)
    show_map = extract_shows(tms_ids)
    data = apply_show_overrides(live_data, show_map)
    data
  end


  private

  def extract_tms_ids(live_data)
    live_data.each_with_object(Set.new) do |station, set|
      station['airings'].each do |airing|
        set.add(airing['program']['tmsId'])
      end
    end
  end

  def extract_shows(tms_ids)
    memo = {}
    Show.includes(:parent_program)
      .select(:id, :tmsId, :popularity_score, :preferred_image_uri, :seriesId, :rootId)
      .where(tmsId: tms_ids)
      .order('popularity_score DESC')
      .find_each do |show|
        memo[show.tmsId] = show
      end
    memo
  end

  # use our preferried image, assign popularity_score, etc.
  def apply_show_overrides(live_data, show_map)
    live_data.map do |data|
      data['airings'] = data['airings'].map do |airing|
        program = show_map[airing['program']['tmsId']]
        # We have our own "preferredImage" logic, so let's use it when available.
        airing['program']['preferredImage'] = { 'uri' => program.preferred_image_uri } if program&.preferred_image_uri
        airing['program']['popularity_score'] = program&.parent_program&.popularity_score || program&.popularity_score
        airing
      end

      data
    end
  end

  # need to send endDateTime to front end, and then use that as startDateTime for the next batch of pagination
  def get_lineup_api_url
    end_time = @start_time + 14.days
    station_ids = @station_id || Networks::LIST.map { |n| n[:stationId] }.join(',')

    url = "https://data.tmsapi.com/v1.1/lineups/#{@lineup}/grid?startDateTime=#{@start_time.iso8601}&endDateTime=#{end_time.iso8601}&stationId=#{station_ids}&imageAspectTV=4x3&imageSize=Md&imageText=true&excludeChannels=ppv,adult&api_key=#{ENV['TMS_API_KEY']}"
  end
end
