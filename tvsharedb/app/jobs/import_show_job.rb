class ImportShowJob < ApplicationJob
  queue_as :default

  # We want to import the root program record
  # If the root tmsID ("SH" or "MV", not an individual episode "EP") is available,
  # use it. Otherwise, use the seriesId to get the root tmsId.
  #
  # options example:
  # { tmsId: 'SH002960010000' } or
  # { seriesId: '184483' }
  def perform(options)
    program = HTTParty.get api_url(options)
    import_show(program)

    # import a show's episodes
    if program['seriesId'].present?
      import_episodes(program['seriesId'])
    end
  end

  def import_show(program)
    show = Show.find_or_initialize_by(tmsId: program['tmsId'])
    show.update({
      rootId: program['rootId'],
      seriesId: program['seriesId'],
      subType: program['subType'],
      title: program['title'],
      episodeTitle: program['episodeTitle'],
      episodeNum: program['episodeNum'],
      seasonNum: program['seasonNum'],
      releaseYear: program['releaseYear'],
      releaseDate: program['releaseDate'],
      origAirDate: program['origAirDate'],
      titleLang: program['titleLang'],
      descriptionLang: program['descriptionLang'],
      entityType: program['entityType'],
      genres: program['genres'],
      longDescription: program['longDescription'],
      shortDescription: program['shortDescription'],
      runTime: program['runTime'],
      preferred_image_uri: program.dig('preferredImage', 'uri'),
      updated_at: Time.now, # record an attempt to update even if data isn't changed
    })
  end

  def import_episodes(series_id, offset = 0)
    page_response = HTTParty.get("https://data.tmsapi.com/v1.1/series/#{series_id}/episodes?api_key=#{ENV['TMS_API_KEY']}&offset=#{offset}&titleLang=en&descriptionLang=en")

    if page_response['errorCode']
      return # no more episodes
    end

    max_offset = page_response['hitCount']

    page_response['hits'].each do |episode|
      import_show(episode)
      offset += 1
    end

    unless offset >= max_offset
      import_episodes(series_id, offset)
    end
  end

  private

  def api_url(options)
    if options[:tmsId]
      "http://data.tmsapi.com/v1.1/programs/#{options[:tmsId]}?api_key=#{ENV['TMS_API_KEY']}&titleLang=en&descriptionLang=en";
    else
      "http://data.tmsapi.com/v1.1/series/#{options[:seriesId]}?api_key=#{ENV['TMS_API_KEY']}&titleLang=en&descriptionLang=en";
    end
  end
end
