# == Schema Information
#
# Table name: story_sources
#
#  id              :bigint           not null, primary key
#  domain          :string           not null
#  image_url       :string
#  iframe_enabled  :boolean          default(FALSE)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  last_scraped_at :time
#  enabled         :boolean          default(TRUE)
#
require 'test_helper'

class StorySourceTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
