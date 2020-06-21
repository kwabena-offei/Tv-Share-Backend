class Show < ApplicationRecord
  has_many :comments
  has_many :likes
  has_many :awards
  accepts_nested_attributes_for :awards
  has_many :casts
  accepts_nested_attributes_for :casts
  has_many :crews
  accepts_nested_attributes_for :crews
  has_one :keyword
  accepts_nested_attributes_for :keyword
  has_one :preferred_image
  accepts_nested_attributes_for :preferred_image
  has_one :quality_rating
  accepts_nested_attributes_for :quality_rating
  has_many :ratings
  accepts_nested_attributes_for :ratings
  has_many :recommendations
  accepts_nested_attributes_for :recommendations
end
