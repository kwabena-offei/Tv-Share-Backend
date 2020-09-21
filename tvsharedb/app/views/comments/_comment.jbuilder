json.extract! comment, :id, :text, :show_id, :images, :videos, :created_at
json.likes_count comment.likes_count || 0
json.sub_comments_count comment.sub_comments_count || 0
json.shares_count comment.shares_count || 0
json.created_at_formatted distance_of_time_in_words(comment.created_at, Time.current)
json.current_user_liked @current_user_liked_ids&.include?(comment.id) || false
json.current_user_replied @current_user_reply_comment_ids&.include?(comment.id) || false

json.user do
  json.id comment&.user&.id
  json.username comment&.user&.username
end
