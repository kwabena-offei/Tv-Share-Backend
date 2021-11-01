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
end
