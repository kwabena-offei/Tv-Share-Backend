class Admin::MatchingController < AdminController
  skip_before_action :verify_authenticity_token

  def index
  end

  def shows
    data = Show.originals.order(:title)
    render json: data
  end

  def match
    if params[:id].present? && params[:tms_id].present?
      import_show(params[:id], params[:tms_id])
    else
      raise "Show ID and TMS ID must be present"
    end

    render json: :ok
  end

  def possible_matches
    encoded_title = URI::encode(params[:title])
    api_url = "http://data.tmsapi.com/v1.1/programs/search?q=#{encoded_title}&queryFields=title&titleLang=en&descriptionLang=en&api_key=#{ENV['TMS_API_KEY']}"
    api_response = HTTParty.get(api_url)
    render json: api_response['hits']
  end

  def import_show(id, tms_id)
    api_url = "http://data.tmsapi.com/v1.1/programs/#{tms_id}?api_key=#{ENV['TMS_API_KEY']}"
    show = Show.originals.find(id)
    program = HTTParty.get(api_url)
    # Save the TMS/Root ID/Series ID values
    show.update!({
      rootId: program['rootId'],
      tmsId: program['tmsId'],
      seriesId: program['seriesId'],
    })
    # Import the show to get all attributes
    ImportShowJob.perform_later(tmsId: show.tmsId, rootId: show.rootId)
  end
end
