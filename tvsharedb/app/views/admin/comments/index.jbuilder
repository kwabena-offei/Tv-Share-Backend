json.array!(@comments) do |comment|
  json.extract! comment, :id, :text, :show_id, :story_id, :mute_notifications, :images, :videos, :created_at
  json.tmsId comment&.show&.tmsId
  json.likes_count comment.likes_count || 0
  json.sub_comments_count comment.sub_comments_count || 0
  json.shares_count comment.shares_count || 0
  json.image_count comment.images&.count || 0
  json.video_count comment.videos&.count || 0
  json.has_profanity ProfanityFilter::Base.profane?(comment.text)

  json.user do
    json.id comment&.user&.id
    json.username comment&.user&.username
    json.image comment&.user&.image
  end
end