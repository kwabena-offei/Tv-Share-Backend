# == Schema Information
#
# Table name: shares
#
#  id             :bigint           not null, primary key
#  user_id        :bigint
#  shareable_id   :integer          not null
#  shareable_type :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
class Share < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :shareable, polymorphic: true, counter_cache: true
end
