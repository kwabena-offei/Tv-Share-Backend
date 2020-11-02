# AKA "News"
class Story < ApplicationRecord
  include AlgoliaSearch

  algoliasearch enqueue: true do
    attributes [:title, :description, :image_url, :source, :get_source_domain]
    searchableAttributes [:title, 'unordered(description)', :source, :get_source_domain]
    customRanking ['desc(likes_count)', 'desc(shares_count)']
  end

  before_validation :associate_with_source
  belongs_to :story_source
  belongs_to :show, optional: true, counter_cache: true
  has_many :likes
  has_many :shares, as: :shareable

  def get_source_domain
    URI.parse(url).host.split('www.').last
  end

  private

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
