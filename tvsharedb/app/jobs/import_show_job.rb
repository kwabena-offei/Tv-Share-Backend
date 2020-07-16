class ImportShowJob < ApplicationJob
  queue_as :default

  def perform(tmsId)
    program = HTTParty.get api_url(tmsId)
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

  def api_url(tms_id)
    "http://data.tmsapi.com/v1.1/programs/#{tms_id}?api_key=#{ENV['TMS_API_KEY']}";
  end
end
