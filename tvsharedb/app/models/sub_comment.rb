class SubComment < ApplicationRecord
  belongs_to :comment, counter_cache: true
  belongs_to :user
end
