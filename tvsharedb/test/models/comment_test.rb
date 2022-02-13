# == Schema Information
#
# Table name: comments
#
#  id                 :bigint           not null, primary key
#  text               :string
#  hashtag            :string
#  user_id            :bigint           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  show_id            :bigint
#  images             :text             default([]), is an Array
#  likes_count        :integer
#  sub_comments_count :integer
#  videos             :text             default([]), is an Array
#  shares_count       :bigint           default(0)
#  story_id           :integer
#  mute_notifications :boolean          default(FALSE)
#  status             :integer          default("active")
#  parent_show_tms_id :string
#
require 'test_helper'

class CommentTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
