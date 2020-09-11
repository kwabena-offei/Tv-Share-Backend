# AKA "News"
class Story < ApplicationRecord
  belongs_to :show, optional: true
  has_many :likes
end
