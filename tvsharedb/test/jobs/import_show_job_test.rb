require 'test_helper'

class ImportShowJobTest < ActiveJob::TestCase
  test 'show is imported via Gracenote API' do
    tms_id = 'SH006883590000'

    VCR.use_cassette(tms_id) do
      assert_difference('Show.count', 1) do
        ImportShowJob.perform_now(tms_id)
      end
    end

    show = Show.find_by(tmsId: tms_id)
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
