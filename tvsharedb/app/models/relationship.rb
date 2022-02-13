# == Schema Information
#
# Table name: relationships
#
#  id          :bigint           not null, primary key
#  follower_id :integer          not null
#  followed_id :integer          not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Relationship < ApplicationRecord
  belongs_to :followed_user, class_name: 'User', foreign_key: :followed_id, counter_cache: :followed_users_count, optional: true
  belongs_to :follower_user, class_name: 'User', foreign_key: :follower_id, counter_cache: :followers_count, optional: true
end
