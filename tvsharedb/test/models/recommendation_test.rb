# == Schema Information
#
# Table name: recommendations
#
#  id         :bigint           not null, primary key
#  rootId     :string
#  title      :string
#  tmsId      :string
#  show_id    :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require 'test_helper'

class RecommendationTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
