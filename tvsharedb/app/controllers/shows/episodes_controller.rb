class Shows::EpisodesController < ApplicationController
  
  def index
    Rails.logger.info "EpisodesController#index called with id=#{params[:id]}, season=#{params[:season]}"
    
    @show = find_or_import_show
    if @show.blank?
      Rails.logger.error "EpisodesController: Could not find or import show #{params[:id]}"
      return head(:not_found)
    end
    
    Rails.logger.info "EpisodesController: Found show #{@show.tmsId}, seriesId=#{@show.seriesId}, entityType=#{@show.entityType}"
    
    # Get the series ID - works for both show and episode tmsIds
    series_id = @show.seriesId
    
    if series_id.blank?
      Rails.logger.error "EpisodesController: Show has no seriesId"
      return head(:not_found)
    end
    
    # If specific season requested, fetch just that season (with on-demand import)
    if params[:season].present?
      @episodes = fetch_season_episodes(series_id, params[:season])
      Rails.logger.info "EpisodesController: Returning #{@episodes.count} episodes for season #{params[:season]}"
      render json: @episodes
    else
      # Return all episodes grouped by season
      # Only require seasonNum and episodeNum
      @episodes_by_season = Show.where(seriesId: series_id)
                                .where.not(seasonNum: nil, episodeNum: nil)
                                .order(:seasonNum, :episodeNum)
                                .group_by(&:seasonNum)
                                
      Rails.logger.info "EpisodesController: Returning episodes for #{@episodes_by_season.keys.count} seasons"
      render json: @episodes_by_season
    end
  end

  private

  def find_or_import_show
    # Note: params[:id] could be either a tmsId or a seriesId
    # Try tmsId first
    show = Show.find_by(tmsId: params[:id])
    
    if show.blank?
      Rails.logger.info "EpisodesController: Show #{params[:id]} not found by tmsId, trying seriesId..."
      # Try to find by seriesId
      show = Show.find_by(seriesId: params[:id], entityType: 'Show')
      
      if show.blank?
        Rails.logger.info "EpisodesController: Not found by seriesId either, importing..."
        # Try importing - could be either tmsId or seriesId
        if params[:id].start_with?('SH', 'MV', 'EP')
          # It's a tmsId
          ImportShowJob.perform_now(tmsId: params[:id], import_episodes: false)
          show = Show.find_by(tmsId: params[:id])
        else
          # It's a seriesId (numeric)
          ImportShowJob.perform_now(seriesId: params[:id], import_episodes: true)
          show = Show.find_by(seriesId: params[:id], entityType: 'Show')
        end
      end
    else
      Rails.logger.info "EpisodesController: Found show #{show.tmsId} by tmsId"
    end
    
    show
  end
  
  def fetch_season_episodes(series_id, season_num)
    # Only require episodeNum (not episodeTitle) (handles soap operas, etc.)
    episodes = Show.where(seriesId: series_id, seasonNum: season_num)
                   .where.not(episodeNum: nil)
                   .order(:episodeNum)
    
    # If no episodes found for this season, import them on-demand
    if episodes.empty? && series_id.present?
      Rails.logger.info "EpisodesController: No episodes found for season #{season_num}, importing on-demand..."
      import_season_episodes(series_id, season_num)
      episodes = Show.where(seriesId: series_id, seasonNum: season_num)
                     .where.not(episodeNum: nil)
                     .order(:episodeNum)
      Rails.logger.info "EpisodesController: After import, found #{episodes.count} valid episodes"
    end
    
    episodes
  end
  
  def import_season_episodes(series_id, season_num)
    gracenote_api = GracenoteApi.new(requested_by: self.class)
    api_response = gracenote_api.get(
      "https://data.tmsapi.com/v1.1/series/#{series_id}/episodes?season=#{season_num}&api_key=#{ENV['TMS_API_KEY']}"
    )
    
    Rails.logger.info "EpisodesController: Gracenote API response type: #{api_response.class}"
    
    if api_response && api_response.is_a?(Array)
      # Response is directly an array of episodes
      Rails.logger.info "EpisodesController: Importing #{api_response.length} episodes from array"
      api_response.each do |episode_data|
        ImportShowJob.new.import_show(episode_data) if episode_data
      end
    elsif api_response && api_response['hits']
      # Response has 'hits' wrapper
      Rails.logger.info "EpisodesController: Importing #{api_response['hits'].length} episodes from hits"
      api_response['hits'].each do |episode_data|
        program = episode_data['program'] || episode_data
        ImportShowJob.new.import_show(program) if program
      end
    else
      Rails.logger.error "EpisodesController: Unexpected API response format"
    end
  end
end