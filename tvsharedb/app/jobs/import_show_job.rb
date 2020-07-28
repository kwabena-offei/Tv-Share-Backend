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
  end

  def import_show(program)
    show = Show.find_or_initialize_by(tmsId: program['tmsId'])
    show.update({
      rootId: program['rootId'],
      seriesId: program['seriesId'],
      subType: program['subType'],
      title: program['title'],
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

  def api_url(options)
    if options[:tmsId]
      "http://data.tmsapi.com/v1.1/programs/#{options[:tmsId]}?api_key=#{ENV['TMS_API_KEY']}";
    else
      "http://data.tmsapi.com/v1.1/series/#{options[:seriesId]}?api_key=#{ENV['TMS_API_KEY']}";
    end
  end
end
