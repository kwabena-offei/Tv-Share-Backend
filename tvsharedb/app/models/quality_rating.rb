# == Schema Information
#
# Table name: quality_ratings
#
#  id          :bigint           not null, primary key
#  ratingsBody :string
#  value       :string
#  show_id     :bigint
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class QualityRating < ApplicationRecord
  belongs_to :show
end
