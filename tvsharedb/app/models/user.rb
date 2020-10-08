class User < ApplicationRecord
  has_secure_password
  has_many :comments, dependent: :destroy
  has_many :sub_comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :shares

  has_many :active_relationships, class_name: 'Relationship', foreign_key: 'follower_id', dependent: :destroy
  has_many :passive_relationships, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy
  has_many :followed_users, through: :active_relationships, source: :followed_user
  has_many :followers, through: :passive_relationships, source: :follower_user
end
