class ImportOriginalNetworkJob < ApplicationJob
  queue_as :default

  def perform(show)
    @show = show
    import_networks if show.imdb_id
  end

  def import_networks
    data = JSON.parse(fetch_data.body)
    import_network(data) if data.dig('network', 'name')
    import_streaming_network(data) if data.dig('webChannel', 'name')
  end

  def import_network(data)
    external_network_name = data['network']['name']
    internal_network_name = Networks::TV_MAZE_MAP[external_network_name]

    if internal_network_name
      network = Network.find_by(display_name: internal_network_name)
      @show.networks << network unless @show.networks.include?(network)
    else
      p "Network mapping for #{external_network_name} not found"
    end
  end

  def import_streaming_network(data)
    external_network_name = data.dig('webChannel', 'name')

    if external_network_name == 'Netflix'
      @show.netflix!
    elsif external_network_name == 'Hulu'
      @show.hulu!
    end
  end

  private

  def fetch_data
    HTTParty.get(api_url)
  end

  def api_url
    "http://api.tvmaze.com/lookup/shows?imdb=#{@show.imdb_id}"
  end
end
