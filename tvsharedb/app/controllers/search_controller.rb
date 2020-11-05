class SearchController < ApplicationController
  def index
    render json: [
      { label: 'Programs', options: program_options },
      { label: 'News', options: news_options },
      { label: 'Comments', options: comment_options },
    ]
  end

  private

  def program_options
    Show.with_tms_id.non_episode
    .where("LOWER(title) LIKE ?", "%#{params[:query].downcase}%")
    .order(:title, :popularity_score)
    .limit(10).find_each.map do |show|
      {
        type: 'show',
        value: show.tmsId,
        label: show.title,
        year: show.releaseYear,
        image: show.preferred_image_uri,
        genre: show.genres&.first,
        sub_type: show.subType,
        cast: show.cast&.first(2)&.map { |cast| cast['name'] }&.join(', ')
      }
    end
  end

  def news_options
    Story
    .joins(:show)
    .where.not(image_url: nil)
    .where("LOWER(stories.title) LIKE ?", "%#{params[:query].downcase}%")
    .order(:title, :published_at, :likes_count)
    .limit(5).find_each.map do |story|
      {
        type: 'story',
        value: story.id,
        show_tms_id: story.show.tmsId,
        label: story.title,
        image: story.image_url,
        source: story.get_source_domain
      }
    end
  end

  def comment_options
    Comment
    .includes(:show, :user)
    .where("LOWER(text) LIKE ?", "%#{params[:query].downcase}%")
    .order(:text, :created_at, :likes_count)
    .limit(5).find_each.map do |comment|
      {
        type: 'comment',
        value: comment.id,
        show_tms_id: comment.show.tmsId,
        label: comment.text,
        image: comment.images&.first,
        username: comment.user.username
      }
    end
  end
end
