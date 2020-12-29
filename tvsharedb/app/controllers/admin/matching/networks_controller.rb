class  Admin::Matching::NetworksController < Admin::MatchingController

  def index
    render json: Network.where.not(display_name: nil)
  end

  def shows
    render json: Show.
    where("\"tmsId\" like 'SH%'").
    where(networks_count: 0, original_streaming_network: nil).
    order(episodes_count: :desc).where('episodes_count > 3').
    where(titleLang: 'en').
    where(descriptionLang: 'en').
    where.not(releaseYear: nil).
    exclude_genre('Adults only').
    limit(25_00)
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
