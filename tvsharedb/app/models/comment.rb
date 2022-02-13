# == Schema Information
#
# Table name: comments
#
#  id                 :bigint           not null, primary key
#  text               :string
#  hashtag            :string
#  user_id            :bigint           not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  show_id            :bigint
#  images             :text             default([]), is an Array
#  likes_count        :integer
#  sub_comments_count :integer
#  videos             :text             default([]), is an Array
#  shares_count       :bigint           default(0)
#  story_id           :integer
#  mute_notifications :boolean          default(FALSE)
#  status             :integer          default("active")
#  parent_show_tms_id :string
#
class Comment < ApplicationRecord
  include Reportable
  include Notifiable
  enum status: [:active, :inactive]

  belongs_to :user, counter_cache: true, optional: true
  belongs_to :show, counter_cache: true, optional: true
  belongs_to :story, counter_cache: true, optional: true
  has_many :likes, dependent: :destroy
  has_many :sub_comments, dependent: :destroy
  has_many :shares, as: :shareable
  
  after_create :broadcast

  def show_title
    show&.title
  end

  def short_text
    text&.truncate(500)
  end

  def preview_image
    images&.first
  end

  def as_json(options = {})
    super(options).merge({ tmsId: show&.tmsId })
  end

  def subject
    if show_id.present?
      show
    elsif story_id.present?
      story
    end
  end

  def broadcast
    CommentsChannel.broadcast_to(subject, websocket_data)
  end

  def websocket_data
    string = ApplicationController.render(
      partial: 'comments/comment.jbuilder',
      locals: { comment: self }
    )
    JSON.parse(string) if string.present?
  end
end
