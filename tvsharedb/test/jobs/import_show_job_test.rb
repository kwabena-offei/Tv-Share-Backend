require 'test_helper'

class ImportShowJobTest < ActiveJob::TestCase
  setup do
    @movie_tms_id = 'MV003358300000'
    @tms_id = 'SH006883590000'
    @series_id = '185044'
  end

  test 'show is imported via TMS ID and Gracenote API' do
    VCR.use_cassette(@tms_id) do
      assert_difference('Show.count', 268) do
        ImportShowJob.perform_now(tmsId: @tms_id)
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

  test 'show and episodes are imported via Series ID and Gracenote API' do
    VCR.use_cassette("series_#{@series_id}") do
      assert_difference('Show.count', 268) do
        ImportShowJob.perform_now(seriesId: @series_id)
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

  test 'movies are imported via TMS ID API' do
    VCR.use_cassette("tms_id#{@movie_tms_id}") do
      assert_difference('Show.count', 1) do
        ImportShowJob.perform_now(tmsId: @movie_tms_id)
      end
    end

    show = Show.find_by(tmsId: @movie_tms_id)
    assert_equal 'Big Mommas: Like Father, Like Son', show.title
    assert_equal 'Movie', show.entityType
    assert_equal nil, show.origAirDate
    assert_equal '2011-02-18', show.releaseDate.to_s
    assert_equal 2011, show.releaseYear
    assert_equal '8329393', show.rootId
    assert_equal nil, show.seriesId
    assert_equal 'Feature Film', show.subType
    assert_equal 'en', show.titleLang
    assert_equal ['Comedy'], show.genres
    assert_equal 'http://wewe.tmsimg.com/assets/p8329393_v_v5_ab.jpg', show.preferred_image_uri
  end
end
