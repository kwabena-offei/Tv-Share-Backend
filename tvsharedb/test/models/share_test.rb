# == Schema Information
#
# Table name: shares
#
#  id             :bigint           not null, primary key
#  user_id        :bigint
#  shareable_id   :integer          not null
#  shareable_type :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
require 'test_helper'

class ShareTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
