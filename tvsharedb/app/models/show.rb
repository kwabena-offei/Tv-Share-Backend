class Show < ApplicationRecord
  has_many :comments
  has_many :likes
  has_many :awards
  has_many :casts
  has_many :crews
  has_many :keywords
  has_one :preferredImage
  has_one :quality_rating
  has_many :ratings
  has_many :recommendations
end
