class Shows::EpisodesController < ApplicationController
  def index
   # Rails.logger.info "EpisodesController#index called with id=#{params[:id]}, season=#{params[:season]}"
    
    @series = find_parent_series
    if @series.blank?
      Rails.logger.error "EpisodesController: Could not find or import parent series for #{params[:id]}"
      return render json: { episodes: [], importing: true }
    end
    
   # Rails.logger.info "EpisodesController: Found series #{@series.tmsId}, seriesId=#{@series.seriesId}"
  
    episodes = Show.where(seriesId: @series.seriesId, entityType: 'Episode').order(created_at: :desc)
    total_episodes_from_metadata = @series.totalEpisodes.to_i
    count_mismatch = total_episodes_from_metadata > 0 && episodes.count < total_episodes_from_metadata

    is_importing = if count_mismatch
      latest_episode = episodes.first
      time_since_last_import = latest_episode ? Time.current - latest_episode.created_at : nil
      
      time_since_last_import && time_since_last_import < 15.seconds
    else
      false
    end

    if params[:season].present?
      season_num = params[:season]
      
      # Run a synchronous import for the requested season.
      if @series.seriesId.present?
      #  Rails.logger.info "EpisodesController: Prioritizing season #{season_num} import."
        import_season_episodes(@series.seriesId, season_num)
      end

      # After the priority import, fetch the definitive list of episodes for this season.
      episodes = Show.where(seriesId: @series.seriesId, seasonNum: season_num)
                     .where.not(episodeNum: nil)
                     .order(:episodeNum)
      
      final_importing_flag = false

     # Rails.logger.info "EpisodesController: Returning #{episodes.count} episodes for season #{season_num}."
      render json: { episodes: episodes, importing: final_importing_flag }
    else
      @episodes_by_season = Show.where(seriesId: @series.seriesId)
                                .where.not(seasonNum: nil, episodeNum: nil)
                                .order(:seasonNum, :episodeNum)
                                .group_by(&:seasonNum)
                                
     # Rails.logger.info "EpisodesController: Returning episodes for #{@episodes_by_season.keys.count} seasons. Importing: #{is_importing}"
      render json: { episodes: @episodes_by_season.values.flatten, importing: is_importing }
    end
  end

  private

  def find_parent_series
    show_or_episode = Show.find_by(tmsId: params[:id])

    series_id = if show_or_episode
      show_or_episode.seriesId
    elsif params[:id].match?(/^\d+$/)
      params[:id]
    end

    return nil if series_id.blank?

    parent_series = Show.find_by(seriesId: series_id, entityType: 'Show')

    if parent_series.blank?
     # Rails.logger.info "EpisodesController: Parent series #{series_id} not found, importing metadata now."
      ImportShowJob.perform_now(seriesId: series_id, import_episodes: false)
      parent_series = Show.find_by(seriesId: series_id, entityType: 'Show')
    end
    
    parent_series
  end
  
  def import_season_episodes(series_id, season_num)
    gracenote_api = GracenoteApi.new(requested_by: self.class)
    api_response = gracenote_api.get(
      "https://data.tmsapi.com/v1.1/series/#{series_id}/episodes?season=#{season_num}&api_key=#{ENV['TMS_API_KEY']}"
    )
    
    Rails.logger.info "EpisodesController: Gracenote API response type: #{api_response.class}"
    
    if api_response && api_response.is_a?(Array)
      Rails.logger.info "EpisodesController: Bulk importing #{api_response.length} episodes"
      ImportShowJob.new.bulk_import_episodes(api_response)
    elsif api_response && api_response['hits']
      episodes = api_response['hits'].map { |episode_data| episode_data['program'] || episode_data }
      Rails.logger.info "EpisodesController: Bulk importing #{episodes.length} episodes from hits"
      ImportShowJob.new.bulk_import_episodes(episodes)
    else
      Rails.logger.error "EpisodesController: Unexpected API response format for series #{series_id}, season #{season_num}"
    end
  end
end