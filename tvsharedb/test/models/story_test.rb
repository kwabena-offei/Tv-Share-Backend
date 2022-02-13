# == Schema Information
#
# Table name: stories
#
#  id              :bigint           not null, primary key
#  title           :string           not null
#  description     :text             not null
#  source          :text
#  image_url       :string
#  url             :string           not null
#  published_at    :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  show_id         :integer
#  likes_count     :bigint
#  shares_count    :bigint           default(0)
#  story_source_id :bigint
#  comments_count  :integer
#
require 'test_helper'

class StoryTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
