# == Schema Information
#
# Table name: keywords
#
#  id          :bigint           not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  Character   :string           default([]), is an Array
#  Mood        :string           default([]), is an Array
#  Setting     :string           default([]), is an Array
#  Subject     :string           default([]), is an Array
#  Theme       :string           default([]), is an Array
#  Time_Period :string           default([]), is an Array
#  show_id     :bigint
#
require 'test_helper'

class KeywordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
