# == Schema Information
#
# Table name: show_searches
#
#  title               :string
#  id                  :bigint
#  tmsId               :string
#  preferred_image_uri :string
#  releaseYear         :integer
#  genres              :string           is an Array
#  subType             :string
#  cast                :json             is an Array
#  popularity_score    :integer
#  lower_title         :text
#
class ShowSearch < ApplicationRecord
  scope :by_title, -> (query) { where('lower_title LIKE ?', "%#{query.downcase}%") }
  scope :ordered_by_match_and_popularity, -> (query) do
    order("
      case
      when lower_title LIKE '#{query.downcase}' then 5000 + popularity_score
      when lower_title LIKE '#{query.downcase}%' then 20 + popularity_score
      when lower_title LIKE '%#{query.downcase}%' then 5 + popularity_score
        else 1 + popularity_score
      end DESC")
  end

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end
end
