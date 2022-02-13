# == Schema Information
#
# Table name: reports
#
#  id              :bigint           not null, primary key
#  message         :string
#  user_id         :bigint           not null
#  reportable_type :string           not null
#  reportable_id   :bigint           not null
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  url             :string
#
require 'test_helper'

class ReportTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
