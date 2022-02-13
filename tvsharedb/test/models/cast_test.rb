# == Schema Information
#
# Table name: casts
#
#  id            :bigint           not null, primary key
#  billingOrder  :string
#  characterName :string
#  name          :string
#  nameId        :string
#  personId      :string
#  role          :string
#  show_id       :bigint
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
require 'test_helper'

class CastTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
