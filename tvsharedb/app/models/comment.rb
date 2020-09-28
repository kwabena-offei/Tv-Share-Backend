class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :show, counter_cache: true
  has_many :likes, dependent: :destroy
  has_many :sub_comments, dependent: :destroy
  has_many :shares, as: :shareable
end
