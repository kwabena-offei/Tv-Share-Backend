# == Schema Information
#
# Table name: ratings
#
#  id         :bigint           not null, primary key
#  body       :string
#  code       :string
#  show_id    :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Rating < ApplicationRecord
  belongs_to :show
end
