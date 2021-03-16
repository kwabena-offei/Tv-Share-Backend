class GuidesController < ActionController::Base
  caches_action :live, expires_in: 1.minutes, cache_path: -> do
    { station_id: request.params[:network_id] }
  end, if: -> { Rails.env.production? }

  caches_action :upcoming, expires_in: 1.minutes, cache_path: -> do
    { station_id: request.params[:network_id], start_time: request.params[:network_id] }
  end, if: -> { Rails.env.production? }

  def live
    render json: LineupCache.new.live_now(station_id: normalized_station_id), as: :text
  end

  def upcoming
    render json: LineupCache.new.upcoming(station_id: normalized_station_id), as: :text
  end

  # Allows for dynamic caching
  def cache_keys
    { station_id: normalized_station_id, genre: request.params[:genre], page: request.params[:page] }
  end

  private

  def normalized_station_id
    params[:station_id] || params[:network_id]
  end
end
