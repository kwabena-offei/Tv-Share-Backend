class AddOriginalStreamingNetworkToShows < ActiveRecord::Migration[6.0]
  def change
    add_column :shows, :original_streaming_network, :integer, null: true
    add_index :shows, :original_streaming_network

    add_column :shows, :original_streaming_network_id, :string, null: true
    add_index :shows, :original_streaming_network_id
  end
end
