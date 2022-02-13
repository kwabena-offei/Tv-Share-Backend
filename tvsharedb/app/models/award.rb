# == Schema Information
#
# Table name: awards
#
#  id         :bigint           not null, primary key
#  awardCatId :string
#  awardId    :string
#  awardName  :string
#  category   :string
#  name       :string
#  year       :string
#  show_id    :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  personId   :string
#  won        :boolean
#
class Award < ApplicationRecord
  belongs_to :show, counter_cache: true
end
