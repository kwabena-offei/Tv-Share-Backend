require 'test_helper'

class ShowTest < ActiveSupport::TestCase
  test "tmsId must be unique" do
    tms_id = '123'
    show_1 = Show.create(tmsId: tms_id)
    show_2 = Show.new(tmsId: tms_id)

    assert show_1.valid?
    refute show_2.valid?
  end

  test "original_streaming_network_id must be unique per original_streaming_network" do
    original_streaming_network_id = '123'
    show_1 = Show.create(original_streaming_network_id: original_streaming_network_id, original_streaming_network: :netflix)
    show_2 = Show.new(original_streaming_network_id: original_streaming_network_id, original_streaming_network: :netflix)
    show_3 = Show.new(original_streaming_network_id: original_streaming_network_id, original_streaming_network: :hulu)

    assert show_1.valid?
    refute show_2.valid?

    # this show is on another streaming network, so it should be valid
    assert show_3.valid?
  end
end
