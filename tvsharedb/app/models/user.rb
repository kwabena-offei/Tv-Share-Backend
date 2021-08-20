class User < ApplicationRecord
  acts_as_voter
  has_secure_password
  include Reportable

  validate :password_complexity
  validates :username, :email, presence: true
  validates :username, :email, uniqueness: { case_sensitive: false }
  validates :facebook_id, :email, uniqueness: true, allow_nil: true
  validates :google_id, :email, uniqueness: true, allow_nil: true
  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }

  has_many :comments, dependent: :destroy
  has_many :sub_comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :shares
  has_many :active_relationships, class_name: 'Relationship', foreign_key: 'follower_id', dependent: :destroy
  has_many :passive_relationships, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy
  has_many :followed_users, through: :active_relationships, source: :followed_user
  has_many :followers, through: :passive_relationships, source: :follower_user
  has_many :notifications, foreign_key: :owner_id # notifications where this user is the recipient

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

  # For social logins we base their username off of their email
  # If the username is already taken, append a random string
  def self.get_unique_username(string)
    if User.where(username: string).exists?
      string = User.get_unique_username("#{string}#{rand(1..999)}")
    end

    string
  end

  private

  def password_complexity
    if password.present? && password.to_s.length < 6
      errors.add(:password, 'Password should have 6 or more characters')
    end
  end
end
