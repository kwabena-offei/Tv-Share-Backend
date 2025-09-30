json.partial! partial: 'shared/pagination', records: @users

json.results @users do |user|
  json.extract! user, :id, :username, :image, :bio, :comments_count
  json.is_following @current_user ? @current_user.followed_users.include?(user) : false
end