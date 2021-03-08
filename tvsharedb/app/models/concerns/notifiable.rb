module Notifiable
  extend ActiveSupport::Concern
  attr_accessor :action

  included do
    has_many :notifications, as: :notifiable
    # has_many :notification_action, as: :notifiable
    before_create :generate_message
  end


  def subject
    "#{owner.username} #{}"
  end

  private

  def generate_message
    # likes
    # "#{actor&.username} to your #{action} #{}"

    # self.message = generated_message
  end

end

# User.first.likes.create(comment_id: Comment.last.id)

# replied to your message
# commented on your reaction
# replied to your comment
# liked your reaction (comment / sub_comment)
