class Notification < ApplicationRecord
  belongs_to :actor, class_name: 'User'
  belongs_to :owner, class_name: 'User'
  belongs_to :notifiable, polymorphic: true

  before_validation :assign_owner, on: :create

  scope :unread, -> { where(read_at: nil) }
  after_create :broadcast

  private

  def broadcast
    NotificationsChannel.broadcast_to(owner, websocket_data)
  end

  def assign_owner
    self.owner = notifiable&.user
  end

  def websocket_data
    string = ApplicationController.render(
      partial: 'notifications/notification.jbuilder',
      locals: { notification: self }
    )
    JSON.parse(string) if string.present?
  end
end
