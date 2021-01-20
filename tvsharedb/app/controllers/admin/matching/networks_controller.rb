class  Admin::Matching::NetworksController < Admin::MatchingController

  def index
    networks =  Network.where.not(display_name: nil)
    networks = networks.all.to_a.concat(Show.original_streaming_networks.keys.map do |streaming|
      { id: streaming, display_name: streaming.titlecase }
    end)
    render json: networks
  end

  def shows
    render json: Show.
    with_tms_id.
    where(networks_count: 0, original_streaming_network: nil).
    order(episodes_count: :desc)
    .limit(2_500)
  end

  def match
    Show.assign_network(params[:seriesId], params[:networkId]) if params[:seriesId] && params[:networkId]

    if params[:tmsId]
      @show = Show.find_by(tmsId: params[:tmsId])
      render 'admin/matching/show'
    else
      head(:ok)
    end
  end

  def possible_matches
    render json: Network.where.not(display_name: nil)
  end
end
