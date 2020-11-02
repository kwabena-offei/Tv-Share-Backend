class Show < ApplicationRecord
  enum original_streaming_network: { netflix: 0, hulu: 1 }
  include AlgoliaSearch

  algoliasearch enqueue: true, id: :tmsId, if: :has_tms_id? do
    attributes [:title, :episodeTitle, :tmsId, :entityType, :releaseDate,
      :genres, :original_streaming_network, :preferred_image_uri, :cast, :directors,
      :shortDescription, :longDescription, :releaseYear, :seasonNum, :episodeNum]
    searchableAttributes [:title, :episodeTitle, :cast, :directors,
      :original_streaming_network, :releaseYear, 'unordered(longDescription)']
    customRanking ['desc(comments_count)', 'desc(likes_count)', 'desc(stories_count)']
  end

  has_many :comments, dependent: :destroy
  has_many :likes
  has_many :awards, dependent: :destroy
  accepts_nested_attributes_for :awards
  has_many :casts, dependent: :destroy
  accepts_nested_attributes_for :casts
  has_many :crews, dependent: :destroy
  accepts_nested_attributes_for :crews
  has_one :keyword
  accepts_nested_attributes_for :keyword
  has_one :preferred_image, dependent: :destroy
  accepts_nested_attributes_for :preferred_image
  has_one :quality_rating, dependent: :destroy
  accepts_nested_attributes_for :quality_rating
  has_many :ratings, dependent: :destroy
  accepts_nested_attributes_for :ratings
  has_many :recommendations, dependent: :destroy
  accepts_nested_attributes_for :recommendations
  has_and_belongs_to_many :networks
  has_many :stories

  validates :tmsId, uniqueness: true, allow_blank: true
  validates :original_streaming_network_id, allow_blank: true,
    uniqueness: { scope: :original_streaming_network }

  has_many :shares, as: :shareable

  scope :originals, -> { where.not(original_streaming_network: nil) }
  scope :with_tms_id, -> { where.not(tmsId: nil) }
  scope :without_tms_id, -> { where(tmsId: nil) }
  scope :non_episode, -> { where.not("\"tmsId\" like 'EP%'") }
  scope :exclude_episodes, -> { where(Show.arel_table[:seriesId].matches Show.arel_table[:rootId]) }

  scope :recent_and_upcoming, -> { where(releaseDate: 7.days.ago..2.days.from_now ) }
  scope :aired_within, -> (range) { where(releaseDate: range ) }
  scope :news_imported_older_than, -> (timeframe) { where("imported_news_at < ?", timeframe.ago).or(Show.where(imported_news_at: nil)) }

  # Checks only the first element in the genre array.
  # Quick solution to prevent duplicates across genres.
  scope :by_genre, -> (genre) { where("genres[1] = ?", genre.titlecase) }
  scope :by_genres, -> (genres) { where("genres[1] IN (?)", genres.map(&:titlecase)) }


  def season_and_episode_number
    if episodeNum && seasonNum
      "S#{seasonNum}:E#{episodeNum}"
    end
  end

  def activity_count
    [shares_count, likes_count, comments_count, stories_count].inject(:+) || 0
  end

  # This is used when querying the news-search API
  def news_query
    {
      query_id: news_query_key,
      show_title: title,
      expires: 300
    }
  end

  def news_query_key
    "show-#{id}"
  end

  # used to determine whether it should be indexed by Algolia
  def has_tms_id?
    tmsId.present?
  end
end
