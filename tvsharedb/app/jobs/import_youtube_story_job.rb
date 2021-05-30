class ImportYoutubeStoryJob < ApplicationJob
  SEARCH_TERM = 'popular tv show season'
  MAIL_URL = 'http://www.youtube.com/watch?v='
  queue_as :default

  def perform(*args)
    videos = Yt::Collections::Videos.new
    vidoes_collection = videos.where(q: SEARCH_TERM, safe_search: 'none')
    vidoes_collection.each do |video|
      @story = Story.new(title: video.title, 
                        description: video.description, 
                        image_url: video.thumbnail_url,
                        url: MAIL_URL + video.id
                      )
      unless Story.find_by_url(MAIL_URL + video.id)                 
        @story.save
        puts video.id + 'video has been stored successfully'
      else
        puts 'failed to store the video'  
      end
    end
  end
end