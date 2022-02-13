# == Schema Information
#
# Table name: show_categories
#
#  id          :bigint           not null, primary key
#  show_id     :bigint           not null
#  category_id :bigint           not null
#  position    :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class ShowCategory < ApplicationRecord
  belongs_to :show
  belongs_to :category
  default_scope { order(position: :asc) }
end
