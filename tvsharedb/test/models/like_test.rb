# == Schema Information
#
# Table name: likes
#
#  id             :bigint           not null, primary key
#  like           :boolean
#  user_id        :bigint           not null
#  comment_id     :bigint
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  show_id        :bigint
#  sub_comment_id :bigint
#  story_id       :bigint
#
require 'test_helper'

class LikeTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
