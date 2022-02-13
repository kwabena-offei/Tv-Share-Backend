# == Schema Information
#
# Table name: recommendations
#
#  id         :bigint           not null, primary key
#  rootId     :string
#  title      :string
#  tmsId      :string
#  show_id    :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Recommendation < ApplicationRecord
  belongs_to :show
end
