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

  def generate_reset_password_token
    self.password_reset_token = SecureRandom.urlsafe_base64(32)
    self.password_reset_token_expiration = 3.days.from_now
    self.save!
    UserMailer.with(user: self).reset_password.deliver_now
  end

  def self.reset_password(token, new_password, new_password_confirmation)
    user = User.where('password_reset_token_expiration > ?', Time.current).find_by!(password_reset_token: token)
    user.password = new_password
    user.password_confirmation = new_password_confirmation
    user.password_reset_token = nil
    user.password_reset_token_expiration = nil
    user.save!
  end
end
