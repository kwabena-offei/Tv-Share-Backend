json.partial! @comment, as: :comment

json.likes @comment.likes do |like|
  json.created_at_formatted distance_of_time_in_words(like.created_at, Time.current)
  json.username like&.user&.username
end

json.replies @comment.sub_comments do |sub_comment|
  json.extract! sub_comment, :id, :text
  json.created_at_formatted distance_of_time_in_words(sub_comment.created_at, Time.current)
  json.username sub_comment&.user&.username
end
