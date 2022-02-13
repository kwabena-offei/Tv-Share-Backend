# == Schema Information
#
# Table name: networks
#
#  id           :bigint           not null, primary key
#  name         :string
#  display_name :string
#  streaming    :boolean          default(FALSE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  station_id   :string
#
require 'test_helper'

class NetworkTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
