# Documentation for Gracnote Image Metadata:
# https://developer.tmsapi.com/page/Image_Metadata

# Image Categories:
#
# Banner – source-provided image, usually shows cast ensemble with source-provided text
# Banner-L1 - same as Banner
# Banner-L2 - source-provided image with plain text
# Banner-L3 - stock photo image with plain text
# Banner-LO - banner with Logo Only

# Image tiers:
#
# Series – image represents of series, regardless of season (banner, iconic, staple, cast, logo)
# Season - image represents specific season of series (banner, iconic, cast, logo)
# Episode - image represents specific episode of series (iconics only)
#

# The following program types currently have images that contain a tier value:
#
# Miniseries
# Series
# Sports

class GetShowImage
  attr_accessor :tmsId, :data

  def perform(tmsId)
    @tmsId = tmsId
    @data = HTTParty.get api_url
    get_preferred_image_url
  end

  def get_preferred_image_url
    image_url = tmsId.starts_with?('MV') ? get_movie_image : get_series_image
    image_url = image_url&.dig('uri')

    if image_url.blank?
      Rails.logger.warn("Image not found for #{tmsId}")
    else
      image_url.gsub('http:', 'https:')
    end
  end

  def get_series_image
    data.find do |image|
      image['size'] == 'Lg' &&
      image['text'] == 'yes' &&
      image['aspect'] == '4x3' &&
      image['tier'] == 'Series' &&
      image['category'] == 'Banner-L1T' || image['category'] == 'Banner-L1'
    end
  end

  def get_movie_image
    data.find do |image|
      image['size'] == 'Ms' &&
      image['text'] == 'yes' &&
      image['aspect'] == '4x3' &&
      image['category'] == 'VOD Art'
    end
  end

  def api_url
    # Movie do not have the "large" size.
    image_size = tmsId.starts_with?('MV') ? 'Ms' : 'Lg'
    "http://data.tmsapi.com/v1.1/programs/#{tmsId}/images?imageSize=#{image_size}&imageAspectTV=4x3&imageText=true&api_key=#{ENV['TMS_API_KEY']}"
  end
end
