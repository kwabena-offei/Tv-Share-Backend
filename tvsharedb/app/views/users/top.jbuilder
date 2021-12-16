json.results(@top_commenters) do |top_commenter|
  json.score top_commenter.score
  json.user do
    json.extract! top_commenter.user, :id, :image, :username, :comments_count
  end
end
