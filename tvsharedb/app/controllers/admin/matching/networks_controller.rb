class  Admin::Matching::NetworksController < Admin::MatchingController

  def index
    render json: Network.where.not(display_name: nil)
  end

  def shows
    render json: Show.
    with_tms_id.
    where(networks_count: 0, original_streaming_network: nil).
    order(episodes_count: :desc)
    .limit(2_500)
  end

  def match
    series_id = params[:seriesId]
    network = Network.find(params[:networkId])
    assign_network(series_id, network) if (series_id && network)
    render json: :ok
  end

  def possible_matches
    render json: Network.where.not(display_name: nil)
  end

  private

  def assign_network(series_id, network)
    Show.includes(:networks).where(rootId: series_id).find_each do |show|
      if show.present?
        show.networks << network unless show.networks.include?(network)
        show.save
      end
    end
  end
end
