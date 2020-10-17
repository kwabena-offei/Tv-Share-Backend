require 'whatlanguage'

class ImportShowNewsFromBingWebSearchJob < ApplicationJob
  RESULT_COUNT = 50
  PAGES_TO_SCRAPE = 3
  attr_accessor :show
  queue_as :default

  def perform(show)
    @show = show
    import
    show.imported_news_at = Time.current
    show.save
  end

  def import
    existing_show_stories_urls = Set.new(show.stories.pluck(:url))

    @language_parser = WhatLanguage.new(:all)
    PAGES_TO_SCRAPE.times do |page_num|
      retrieve_search_results(page_num).each do |url|
        next if existing_show_stories_urls.include?(url)

        metadata = get_story_metadata(url)
        next unless metadata['og:type'] == 'article'
        next if metadata['og:locale'].present? && !metadata['og:locale']&.starts_with?('en')
        next unless metadata['og:description'].present? && is_english?(metadata['og:description'])
        next if metadata['og:title'].blank? || metadata['og:title']&.downcase&.include?('wiki')
        next if metadata['og:site_name'].present? && metadata['og:site_name']&.downcase&.include?('wiki') || metadata['og:site_name']&.downcase&.include?('pastebin')

        import_story({
          url: url,
          title: metadata['og:title'],
          source: metadata['og:site_name'],
          description: metadata['og:description'],
          image_url: metadata['og:image'],
          published_at: metadata['article:published_time'] || show.origAirDate
        })
      end
    end
  end

  def import_story(story_data)
    story = Story.find_or_initialize_by(url: story_data[:url])
    story.title = story_data[:title]
    story.description = story_data[:description]
    story.source = story_data[:source]
    story.image_url = story_data[:image_url]
    story.published_at = story_data[:published_at]
    story.show_id = show.id
    story.save
  rescue => e
    puts e
  end

  def retrieve_search_results(page = 0)
    if show.tmsId.starts_with?('EP') && show.title != show.episodeTitle
      query = "#{show.title} \"#{show.episodeTitle}\""
    elsif show.tmsId.starts_with?('MV')
      query = "#{show.title} movie (#{show.releaseYear})"
    else
      query = "#{show.title} review"
    end

    url = "https://api.cognitive.microsoft.com/bing/v7.0/search?q=#{URI.escape(query)}&count=#{RESULT_COUNT}&offset=#{page * RESULT_COUNT}"

    response = HTTParty.get(url, {
      headers: {
        'Ocp-Apim-Subscription-Key' => ENV['BING_API_KEY'],
        'User-Agent' => 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1'
      }
    })

    json = JSON.parse(response.body)
    json['webPages']['value'].map { |result| result['url'] }
  end

  def is_english?(text)
    analysis = @language_parser.process_text(text)
    analysis.sort_by { |lang, count| -count }.first[0]&. == :english
  rescue => e
    puts e
    # language not detected
    false
  end

  def get_story_metadata(url)
    response = HTTParty.get(url, timeout: 5)
    doc = Nokogiri::HTML.parse(response.body)
    properties = {}

    doc.css('meta').each do |meta|
      if meta.attribute('property') && meta.attribute('property').to_s.match(/^og:(.+)$/i) || meta.attribute('property').to_s.match(/^article:(.+)$/i)
        decoded_content = CGI.unescapeHTML(meta.attribute('content').to_s)
        decoded_content = ActionView::Base.full_sanitizer.sanitize(decoded_content)
        properties[meta.attribute('property').to_s] = decoded_content
      end
    end

    properties

  # If the article couldn't be retrieved or parsed, move on to the next URL.
  rescue
    {}
  end
end
