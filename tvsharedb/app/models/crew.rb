# == Schema Information
#
# Table name: crews
#
#  id           :bigint           not null, primary key
#  billingOrder :string
#  name         :string
#  nameId       :string
#  personId     :string
#  role         :string
#  show_id      :bigint
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Crew < ApplicationRecord
  belongs_to :show
end
