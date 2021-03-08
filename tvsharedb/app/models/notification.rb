class Notification < ApplicationRecord
  belongs_to :actor, class_name: 'User'
  belongs_to :owner, class_name: 'User'
  belongs_to :notifiable, polymorphic: true

  before_validation :assign_owner, on: :create

  private

  def assign_owner
    self.owner = notifiable&.user
  end
end
