# == Schema Information
#
# Table name: stories
#
#  id              :bigint           not null, primary key
#  title           :string           not null
#  description     :text             not null
#  source          :text
#  image_url       :string
#  url             :string           not null
#  published_at    :datetime
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  show_id         :integer
#  likes_count     :bigint
#  shares_count    :bigint           default(0)
#  story_source_id :bigint
#  comments_count  :integer
#
# AKA "News"
class Story < ApplicationRecord
  include AlgoliaSearch
  include Reportable

  algoliasearch enqueue: true, auto_index: false do
    attributes [:title, :short_description, :image_url, :source, :get_source_domain, :show_title]
    searchableAttributes [:title, 'unordered(short_description)', :source, :get_source_domain, :show_title]
    customRanking ['desc(likes_count)', 'desc(shares_count)']
  end

  before_validation :associate_with_source
  before_validation :normalize_attributes
  belongs_to :story_source
  belongs_to :show, optional: true, counter_cache: true
  has_many :likes
  has_many :comments, dependent: :destroy
  has_many :shares, as: :shareable

  def get_source_domain
    URI.parse(url).host.split('www.').last
  end

  private

  # Removes leading/trailing spaces and decodes html entities
  # ex: " &amp; " => "&"
  def normalize_attributes
    decoder = HTMLEntities.new

    %i[title description].each do |attr|
      if self[attr]
        self[attr] = decoder.decode(self[attr].strip)
      end
    end
  end

  def show_title
    show&.title
  end

  def short_description
    description&.truncate(500)
  end

  def associate_with_source
    if story_source.nil?
      # we are assigning the story to story_source (rather than
      # the other way around) so that the story_source can use
      # this story's URL to check if iframes are allowed.
      source = StorySource.find_or_initialize_by(domain: get_source_domain)
      source.stories << self
      source.save
    end

    true
  end
end
