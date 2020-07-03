class Show < ApplicationRecord
  has_many :comments, dependent: :destroy
  has_many :likes
  has_many :awards, dependent: :destroy
  accepts_nested_attributes_for :awards
  has_many :casts, dependent: :destroy
  accepts_nested_attributes_for :casts
  has_many :crews, dependent: :destroy
  accepts_nested_attributes_for :crews
  has_one :keyword
  accepts_nested_attributes_for :keyword
  has_one :preferred_image, dependent: :destroy
  accepts_nested_attributes_for :preferred_image
  has_one :quality_rating, dependent: :destroy
  accepts_nested_attributes_for :quality_rating
  has_many :ratings, dependent: :destroy
  accepts_nested_attributes_for :ratings
  has_many :recommendations, dependent: :destroy
  accepts_nested_attributes_for :recommendations
end
