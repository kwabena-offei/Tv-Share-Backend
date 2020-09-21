class Share < ApplicationRecord
  belongs_to :user
  belongs_to :shareable, polymorphic: true, counter_cache: true
end
