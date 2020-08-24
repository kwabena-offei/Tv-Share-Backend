class Show < ApplicationRecord
  enum original_streaming_network: { netflix: 0, hulu: 1 }

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

  validates :tmsId, uniqueness: true, allow_blank: true
  validates :original_streaming_network_id, allow_blank: true,
    uniqueness: { scope: :original_streaming_network }

  scope :originals, -> { where.not(original_streaming_network: nil) }
  scope :with_tms_id, -> { where.not(tmsId: nil) }
  scope :without_tms_id, -> { where(tmsId: nil) }
  scope :non_episode, -> { where.not("\"tmsId\" like 'EP%'") }

  # Checks only the first element in the genre array.
  # Quick solution to prevent duplicates across genres.
  scope :by_genre, -> (genre) { where("genres[1] = ?", genre.titlecase) }
  scope :by_genres, -> (genres) { where("genres[1] IN (?)", genres.map(&:titlecase)) }
end
