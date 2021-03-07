class SubComment < ApplicationRecord
  include Reportable

  belongs_to :comment, counter_cache: true, optional: true
  belongs_to :sub_comment, counter_cache: true, optional: true
  belongs_to :user

  has_many :likes, dependent: :destroy
  has_many :sub_comments, dependent: :destroy
  has_many :shares, as: :shareable
end
