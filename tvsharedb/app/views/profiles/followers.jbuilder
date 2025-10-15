json.partial! partial: 'shared/pagination', records: @users

json.results @users do |user|
  json.extract! user, :id, :username, :image, :bio, :comments_count
  json.is_following @current_user.followed_users.exists?(user.id)
end