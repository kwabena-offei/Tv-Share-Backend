class TopCommenter < ApplicationRecord
  belongs_to :user

  def self.with_profiles(limit: 25)
    self.includes(:user).order(score: :desc).limit(limit)
  end

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end
end
