# == Schema Information
#
# Table name: sub_comments
#
#  id                 :bigint           not null, primary key
#  text               :string
#  hashtag            :string
#  images             :text             default([]), is an Array
#  comment_id         :bigint
#  user_id            :bigint           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  videos             :text             default([]), is an Array
#  shares_count       :bigint           default(0)
#  sub_comment_id     :integer
#  likes_count        :integer          default(0)
#  sub_comments_count :integer          default(0)
#  mute_notifications :boolean          default(FALSE)
#  status             :integer          default("active")
#
class SubComment < ApplicationRecord
  include Reportable
  include Notifiable
  enum status: [:active, :inactive]

  belongs_to :comment, counter_cache: true, optional: true
  belongs_to :sub_comment, counter_cache: true, optional: true
  belongs_to :user

  has_many :likes, dependent: :destroy
  has_many :sub_comments, dependent: :destroy
  has_many :shares, as: :shareable

  after_create :create_notification
  after_create :broadcast

  def subject
    if comment_id.present?
      comment
    elsif sub_comment_id.present?
      sub_comment
    end
  end

  private

  def create_notification
    if comment_id && !comment.mute_notifications
      message = "#{user.username} replied to your comment"
      comment.notifications.create(actor: user, message: message)
    elsif sub_comment_id && !sub_comment.mute_notifications
      message = "#{user.username} replied to your response"
      sub_comment.notifications.create(actor: user, message: message)
    end
  end

  # This should be broadcasted to the comment's websocket channel.
  # Even if this is a reply to a sub_comment - it should bubble up to the comment.
  def broadcast
    websocket_room = SubComment.get_parent_comment(subject)
    CommentsChannel.broadcast_to(websocket_room, websocket_data)
  rescue => e
    Rails.logger.error(e)
  ensure
    true
  end

  def websocket_data
    string = ApplicationController.render(
      partial: 'sub_comments/sub_comment.jbuilder',
      locals: { sub_comment: self }
    )
    JSON.parse(string) if string.present?
  end

  # This returns the original comment of a thread.
  # Handles nested replies.
  def self.get_parent_comment(subject)
    if subject.is_a?(SubComment)
      SubComment.get_parent_comment(subject.subject)
    elsif subject.is_a?(Comment)
      subject
    end
  end
end
