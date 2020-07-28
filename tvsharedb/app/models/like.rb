class Like < ApplicationRecord
  belongs_to :user
  belongs_to :comment, optional: true
  belongs_to :show, optional: true
  belongs_to :sub_comment, optional: true

  scope :for_shows, -> { where.not(show_id: nil) }
end
