class Like < ApplicationRecord
  belongs_to :user
  belongs_to :comment
  belongs_to :show
end
