class GuidesController < ActionController::Base
  include AuthenticationConcerns
  before_action :get_current_user
  before_action :get_lineup
  caches_action :live, expires_in: 1.minutes, cache_path: -> do
    { station_id: request.params[:network_id], timezone: request.params[:timezone] }
  end, if: -> { Rails.env.production? }

  caches_action :upcoming, expires_in: 1.minutes, cache_path: -> do
    { station_id: request.params[:network_id], timezone: request.params[:timezone] }
  end, if: -> { Rails.env.production? }

  def live
    render json: @lineup.live_now(station_id: normalized_station_id), as: :text
  end

  def upcoming
    render json: @lineup.upcoming(station_id: normalized_station_id), as: :text
  end

  # Allows for dynamic caching
  def cache_keys
    { station_id: normalized_station_id, genre: request.params[:genre], page: request.params[:page] }
  end

  private

  def get_lineup
    Rails.logger.info "DEBUG: current_user id=#{@current_user&.id} email=#{@current_user&.email} zipcode=#{@current_user&.zipcode.inspect} auth_header=#{request.headers['Authorization'].present?}"
    if @current_user && @current_user.cable_provider.present?
      @lineup = LineupCache.new(lineup: @current_user.cable_provider)
    elsif @current_user && @current_user.zipcode.present?
      timezone = derive_timezone_from_zipcode(@current_user.zipcode)
      @lineup = LineupCache.new(timezone: timezone)
      Rails.logger.info "DEBUG: User zipcode: #{@current_user&.zipcode}"
      Rails.logger.info "DEBUG: Derived timezone: #{timezone}"
      Rails.logger.info "DEBUG: Selected lineup: #{@lineup.instance_variable_get(:@lineup)}"
    else
      @lineup = LineupCache.new(timezone: request.params[:timezone])
      Rails.logger.info "DEBUG: Skipping linup by Zipcode Derived Timezone"
      Rails.logger.info "DEBUG: User zipcode: #{@current_user&.zipcode}"
      Rails.logger.info "DEBUG: Derived timezone: #{timezone}"
      Rails.logger.info "DEBUG: Selected lineup: #{@lineup.instance_variable_get(:@lineup)}"
    end
  end

  def derive_timezone_from_zipcode(zipcode)
  # Convert Zipcode to Postal Code for call to guide/live endpoint
    case zipcode.to_s
    when /^(10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27)/
      'EST' # East Coast ZIP codes
    when /^(60|61|62|63|64|65|66|67|68|69|70|71|72|73|74|75|76|77|78|79)/
      'CST' # Central ZIP codes  
    when /^(80|81|82|83|84|85|86|87|88|89|90|91|92|93|94|95|96)/
      'MST' # Mountain ZIP codes
    when /^(97|98|99)/
      'PST' # Pacific ZIP codes
    else
      'EST' # Default fallback
    end
  end


  def normalized_station_id
    params[:station_id] || params[:network_id]
  end
end
