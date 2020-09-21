class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :show
  has_many :likes, dependent: :destroy
  has_many :sub_comments, dependent: :destroy
  has_many :shares, as: :shareable
end
