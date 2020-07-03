class User < ApplicationRecord
  has_secure_password
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
end
