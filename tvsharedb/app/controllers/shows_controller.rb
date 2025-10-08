# require_relative '../lib/networks'
# require_relative '../lib/url_api'

class ShowsController < ApplicationController
  # include UrlApi
  include Networks
  before_action :set_show, only: [:show, :update, :destroy]

  # GET /shows
  def index
    @shows = Show.with_tms_id.limit(100)

    render json: @shows
  end

  # GET /shows/1
  def show
    # Build response with metadata
    response_data = @show.as_json(except: [
      :cached_votes_total, :cached_votes_score, :cached_votes_up, :cached_weighted_average,
      :cached_votes_down, :cached_weighted_score, :cached_weighted_total, :imdb_id
    ])
    
    # add parentTmsId and effectiveSeriesId for frontend to use
    if @show.is_show?
      # For shows, parentTmsId is itself
      response_data[:parentTmsId] = @show.tmsId
      response_data[:effectiveSeriesId] = @show.seriesId
      # Ensure totalSeasons/Episodes are numbers (field is string in DB)
      response_data[:totalSeasons] = @show.totalSeasons.to_i if @show.totalSeasons.present?
      response_data[:totalEpisodes] = @show.totalEpisodes.to_i if @show.totalEpisodes.present?
    elsif @show.is_episode?
      # For episodes, use parent show if available
      if @parent_show.present?
        response_data[:parentTmsId] = @parent_show.tmsId
        response_data[:parentTitle] = @parent_show.title
        response_data[:effectiveSeriesId] = @show.seriesId
        # Use parent's metadata (convert string to int)
        response_data[:totalSeasons] = @parent_show.totalSeasons.to_i if @parent_show.totalSeasons.present?
        response_data[:totalEpisodes] = @parent_show.totalEpisodes.to_i if @parent_show.totalEpisodes.present?
      else
        # Fallback: if we don't have parent yet return seriesId for episodes endpoint
        response_data[:parentTmsId] = nil  # Frontend will know to use seriesId
        response_data[:effectiveSeriesId] = @show.seriesId
        response_data[:totalSeasons] = 0
        response_data[:totalEpisodes] = 0
      end
    end
    
    Rails.logger.info "ShowsController#show returning: parentTmsId=#{response_data[:parentTmsId]}, totalSeasons=#{response_data[:totalSeasons]}, seriesId=#{response_data[:effectiveSeriesId]}"
    
    render json: response_data
  end

  # POST /shows
  def create
    # Disabled for now
  end

  # PATCH/PUT /shows/1
  def update
    # Disabled for now
  end

  # DELETE /shows/1
  def destroy
    # Disabled for now
  end

  private

  def set_show
    # Try to find the show first
    @show = Show.find_by(tmsId: params[:id])
    
    # If not found, import it synchronously WITHOUT episodes (fast initial response)
    if @show.blank?
      Rails.logger.info "ShowsController: Importing #{params[:id]} synchronously (metadata only)"
      ImportShowJob.perform_now(tmsId: params[:id], import_episodes: false)
      @show = Show.find_by(tmsId: params[:id])
    end
    
    # If still not found, return 404
    if @show.blank?
      Rails.logger.warn "ShowsController: Could not find or import #{params[:id]}"
      head(:not_found) and return
    end

    if @show.is_episode? && @show.seriesId.present?

      @parent_show = Show.find_by(seriesId: @show.seriesId, entityType: 'Show')
      
      if @parent_show.blank?
        Rails.logger.info "ShowsController: Importing parent show via seriesId #{@show.seriesId} (METADATA ONLY)"
        # Import parent without episodes
        ImportShowJob.perform_now(seriesId: @show.seriesId, import_episodes: false)
        # After import, try to find parent again
        @parent_show = Show.by_series_id_and_type(@show.seriesId) # find_by(seriesId: @show.seriesId, entityType: 'Show')
        Rails.logger.info "ShowsController: Parent show imported - tmsId: #{@parent_show&.tmsId}, totalSeasons: #{@parent_show&.totalSeasons}"
      else
        Rails.logger.info "ShowsController: Parent show #{@parent_show.tmsId} already exists - totalSeasons: #{@parent_show.totalSeasons}"
      end
    end
  end

  def show_params
    params.require(:show).permit(
      :descriptionLang, :entityType, :longDescription, :officialUrl,
      :origAirDate, :releaseDate, :releaseYear, :rootId, :runTime,
      :seriesId, :shortDescription, :subType, :title, :titleLang,
      :tmsId, :totalEpisodes, :totalSeasons,
      :quality_rating_attributes => {},
      :preferred_image_attributes => {},
      :keyword_attributes => {:Character => [], :Mood => [], :Setting => [], :Subject => [], :Theme => [], :Time_Period => []},
      :awards_attributes => [:awardCatId, :awardId, :awardName, :category, :name, :year],
      :casts_attributes => [:billingOrder, :characterName, :name, :nameId, :personId, :role],
      :crews_attributes => [:billingOrder, :name, :nameId, :personId, :role],
      :ratings_attributes => [:body, :code],
      :recommendations_attributes => [:rootId, :title, :tmsId],
      :advisories => [], :directors => [], :genres => [])
  end
end
