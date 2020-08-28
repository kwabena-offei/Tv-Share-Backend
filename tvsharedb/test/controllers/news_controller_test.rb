require 'test_helper'

class NewsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    VCR.use_cassette('bing_recent_news') do
      get news_index_url
    end

    assert_response :success
    assert_equal 'News', json_response['_type']
    assert_equal 'https://www.bing.com/news/search?q=Movie+%26+TV+News&form=TNSA02', json_response['webSearchUrl']
  end
end
