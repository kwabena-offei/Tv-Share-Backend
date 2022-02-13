# == Schema Information
#
# Table name: preferred_images
#
#  id         :bigint           not null, primary key
#  category   :string
#  height     :string
#  primary    :string
#  uri        :text
#  width      :string
#  show_id    :bigint
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class PreferredImage < ApplicationRecord
  belongs_to :show
end
