class TopCommenter < ApplicationRecord
  belongs_to :user

  def self.with_profiles
    top_commenters = self.includes(:user).order(score: :desc)
    users = User.where(id: top_commenters.map(&:user_id)).select(:image, :username, :id).group_by(&:id)

    top_commenters.map do |commenter|
      commenter.attributes.merge({
        user: {
          profile: commenter.user.image,
          username: commenter.user.username,
          id: commenter.user.id
        }
      })
    end
  end

  def self.refresh
    Scenic.database.refresh_materialized_view(table_name, concurrently: false, cascade: false)
  end
end
