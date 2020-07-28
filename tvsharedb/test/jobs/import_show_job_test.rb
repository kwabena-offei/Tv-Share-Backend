require 'test_helper'

class ImportShowJobTest < ActiveJob::TestCase
  setup do
    @tms_id = 'SH006883590000'
    @series_id = '185044'
  end

  test 'show is imported via TMS ID and Gracenote API' do
    @tms_id = 'SH006883590000'

    VCR.use_cassette(@tms_id) do
      assert_difference('Show.count', 1) do
        ImportShowJob.perform_now(tms_id: @tms_id)
      end
    end

    show = Show.find_by(tmsId: @tms_id)
    assert_equal 'House', show.title
    assert_equal 'Show', show.entityType
    assert_equal '2004-11-16', show.origAirDate.to_s
    assert_equal '2004-11-16', show.releaseDate.to_s
    assert_equal 2004, show.releaseYear
    assert_equal '185044', show.rootId
    assert_equal '185044', show.seriesId
    assert_equal 'Series', show.subType
    assert_equal 'en', show.titleLang
    assert_equal ['Drama', 'Mystery', 'Medical'], show.genres
    assert_equal 'http://wewe.tmsimg.com/assets/p8729531_b_v5_ac.jpg', show.preferred_image_uri
  end

  test 'show is imported via Series ID and Gracenote API' do
    VCR.use_cassette("series_#{@series_id}") do
      assert_difference('Show.count', 1) do
        ImportShowJob.perform_now(series_id: @series_id)
      end
    end

    show = Show.find_by(tmsId: @tms_id)
    assert_equal 'House', show.title
    assert_equal 'Show', show.entityType
    assert_equal '2004-11-16', show.origAirDate.to_s
    assert_equal '2004-11-16', show.releaseDate.to_s
    assert_equal 2004, show.releaseYear
    assert_equal '185044', show.rootId
    assert_equal '185044', show.seriesId
    assert_equal 'Series', show.subType
    assert_equal 'en', show.titleLang
    assert_equal ['Drama', 'Mystery', 'Medical'], show.genres
    assert_equal 'http://wewe.tmsimg.com/assets/p8729531_b_v5_ac.jpg', show.preferred_image_uri
  end
end
