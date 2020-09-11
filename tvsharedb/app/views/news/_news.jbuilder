json.extract! story, :id, :title, :description, :source, :image_url, :published_at, :url, :show_id, :likes_count
json.published_at_formatted distance_of_time_in_words(story.published_at || story.created_at, Time.current)
