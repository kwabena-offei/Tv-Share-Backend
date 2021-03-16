class LineupCache
  PAGE_SIZE = 25
  EXPIRATION_DAYS = 7

  def initialize(station_id: nil)
    @station_id = station_id
    @lineup = 'USA-HULU501-DEFAULT'
    @cache_key = "lineup_#{@lineup}"
  end

  def cache(clear_cache: false)
    Rails.cache.fetch(@cache_key, expires_in: EXPIRATION_DAYS.days, force: clear_cache) do
      get_max_live_guide
    end
  end

  def get_max_live_guide
    get_importable_timeslots.each_with_object([]) do |timeslot, array|
      guide = get_guide_timeslot(timeslot)

      # if array.empty?
      #   array = array.concat(guide)
      # else
      #   array = array.map do |station|
      #     station['airings'] = station['airings'].concat(guide)
      #     station
      #   end
      # end
      array.concat(guide)
    end
  end

  def get_guide_timeslot(start_time)
    response = HTTParty.get(get_lineup_api_url(start_time))
    live_data = JSON.parse(response.body)

    tms_ids = extract_tms_ids(live_data)
    show_map = extract_shows(tms_ids)
    apply_show_overrides(live_data, show_map)
  end

  def decorate_guide(live_guide_data)
    tms_ids = extract_tms_ids(live_guide_data)
    show_map = extract_shows(tms_ids)
    apply_show_overrides(live_guide_data, show_map)
  end

  def live_now(station_id: nil)
    guide = self.cache
    guide.map do |station|
      next if station_id.present? && station['stationId'].to_s != station_id.to_s

      current_airing = station['airings'].find do |airing|
        Time.now.utc.between?(airing['startTime'].to_time, airing['endTime'].to_time)
      end

      station['airings'] = current_airing.present? ? [current_airing] : [{program: { preferredImage: {}}}]
      station
    end.compact
  end

  def upcoming(station_id: nil)
    guide = Rails.cache.fetch(@cache_key)
    guide.map do |station|
      next if station_id.present? && station['stationId'].to_s != station_id.to_s

      station['airings'] = station['airings'].select do |airing|
        airing['startTime'].present? && Time.now.utc.before?(airing['startTime'].to_time)
      end

      station
    end.compact
  end

  private

  # returns timestamps in 6 hour increments for the next 14 days
  def get_importable_timeslots
    start_time = Time.current.beginning_of_hour
    end_time = 14.days.from_now.beginning_of_day

    timeslots = []
    (start_time.to_i..end_time.to_i).step(6.hours) do |timeslot|
      timeslots.push(Time.at(timeslot))
    end

    timeslots
  end

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
        airing['program'] = extract_program_data(airing['program'])
        airing = extract_airing_data(airing)
        airing
      end

      data
    end
  end

  def extract_airing_data(airing)
    airing.slice(*%w(stationId callSign affiliateCallSign preferredImage program startTime endTime duration))
  end

  def extract_program_data(program)
    program.slice(*%w(tmsId rootId seriesId title genres preferredImage popularity_score))
  end

  # need to send endDateTime to front end, and then use that as startDateTime for the next batch of pagination
  def get_lineup_api_url(start_time)
    end_time = start_time + 6.hours
    station_ids = Networks::LIST.map { |n| n[:stationId] }.join(',')

    url = "https://data.tmsapi.com/v1.1/lineups/#{@lineup}/grid?startDateTime=#{start_time.iso8601}&endDateTime=#{end_time.iso8601}&stationId=#{station_ids}&imageAspectTV=4x3&imageSize=Md&imageText=true&excludeChannels=ppv,adult&api_key=#{ENV['TMS_API_KEY']}"
  end
end
