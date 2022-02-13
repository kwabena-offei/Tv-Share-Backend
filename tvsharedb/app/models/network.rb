# == Schema Information
#
# Table name: networks
#
#  id           :bigint           not null, primary key
#  name         :string
#  display_name :string
#  streaming    :boolean          default(FALSE)
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  station_id   :string
#
class Network < ApplicationRecord
  has_and_belongs_to_many :shows
  scope :active, -> { Network.where.not(display_name: nil).where.not(station_id: nil) }
end
