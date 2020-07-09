# Calls the Gracenote API for shows airing in the next X hours
# and imports any show that is not yet in our DB
class ImportLiveGuideJob < ApplicationJob
  queue_as :default

  def perform(*args)
    if ENV['TMS_API_KEY'].blank?
      raise 'TMS_API_KEY not found, can not import live guide'
    end

    api_response = HTTParty.get(api_url)
    new_tms_ids = get_new_tms_ids(api_response)

    api_response.each do |result|
      result['airings'].each do |airing|
        program = airing['program']
        import_show(program) if new_tms_ids.include?(program['tmsId'])
      end
    end
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
      runTime: program['runTime']
    })
  end

  def get_new_tms_ids(api_response)
    tms_ids = Set.new

    # build a set of all TMS IDs returned in the API response
    api_response.each do |result|
      result['airings'].each do |airing|
        tms_ids.add(airing['program']['tmsId'])
      end
    end

    # subset of TMS IDs that are already in our database
    db_tms_ids = Show.where(tmsId: tms_ids.to_a).pluck(:tmsId)

    # return TMS IDs that are NOT in the database
    tms_ids.subtract(db_tms_ids)
  end

  def api_url
    # rounds the current time down the the latest 30 minute increment
    timestamp = Time.at(Time.now.to_i - (Time.now.to_i % 30.minutes)).iso8601
    "http://data.tmsapi.com/v1.1/lineups/USA-TX42500-X/grid?startDateTime=#{timestamp}&api_key=#{ENV['TMS_API_KEY']}";
  end
end
