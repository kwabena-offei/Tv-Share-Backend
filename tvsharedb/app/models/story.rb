# AKA "News"
class Story < ApplicationRecord
  belongs_to :show, optional: true
  has_many :likes
  has_many :shares, as: :shareable
end
