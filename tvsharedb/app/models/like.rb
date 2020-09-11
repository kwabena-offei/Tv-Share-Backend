class Like < ApplicationRecord
  belongs_to :user
  belongs_to :comment, optional: true, counter_cache: true
  belongs_to :show, optional: true
  belongs_to :sub_comment, optional: true
  belongs_to :story, optional: true, counter_cache: true

  scope :for_shows, -> { where.not(show_id: nil) }
end
