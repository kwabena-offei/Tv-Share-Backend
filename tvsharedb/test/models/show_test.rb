# == Schema Information
#
# Table name: shows
#
#  id                            :bigint           not null, primary key
#  descriptionLang               :string
#  entityType                    :string
#  longDescription               :text
#  officialUrl                   :text
#  origAirDate                   :date
#  releaseDate                   :string
#  releaseYear                   :integer
#  rootId                        :integer
#  runTime                       :string
#  seriesId                      :string
#  shortDescription              :text
#  subType                       :string
#  title                         :string
#  titleLang                     :string
#  tmsId                         :string
#  totalEpisodes                 :integer
#  totalSeasons                  :string
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  advisories                    :string           default([]), is an Array
#  directors                     :string           default([]), is an Array
#  genres                        :string           default([]), is an Array
#  original_streaming_network    :integer
#  original_streaming_network_id :string
#  preferred_image_uri           :string
#  shares_count                  :bigint           default(0)
#  episodeTitle                  :string
#  episodeNum                    :integer
#  seasonNum                     :integer
#  comments_count                :bigint           default(0)
#  likes_count                   :bigint           default(0)
#  stories_count                 :bigint           default(0)
#  imported_news_at              :datetime
#  cast                          :json             is an Array
#  crew                          :json             is an Array
#  popularity_score              :integer          default(0)
#  awards_count                  :integer          default(0)
#  imdb_id                       :string
#  networks_count                :bigint           default(0)
#  episodes_count                :bigint           default(0)
#  cached_votes_total            :integer          default(0)
#  cached_votes_score            :integer          default(0)
#  cached_votes_up               :integer          default(0)
#  cached_votes_down             :integer          default(0)
#  cached_weighted_score         :integer          default(0)
#  cached_weighted_total         :integer          default(0)
#  cached_weighted_average       :float            default(0.0)
#  rating_percentage_cache       :json
#
require 'test_helper'

class ShowTest < ActiveSupport::TestCase
  setup do
    @show = shows(:one)
    @user_1 = users(:one)
    @user_2 = users(:two)
    @user_3 = users(:three)
  end

  test "tmsId must be unique" do
    tms_id = '123'
    show_1 = Show.create(tmsId: tms_id)
    show_2 = Show.new(tmsId: tms_id)

    assert show_1.valid?
    refute show_2.valid?
  end

  test "original_streaming_network_id must be unique per original_streaming_network" do
    original_streaming_network_id = '123'
    show_1 = Show.create(original_streaming_network_id: original_streaming_network_id, original_streaming_network: :netflix)
    show_2 = Show.new(original_streaming_network_id: original_streaming_network_id, original_streaming_network: :netflix)
    show_3 = Show.new(original_streaming_network_id: original_streaming_network_id, original_streaming_network: :hulu)

    assert show_1.valid?
    refute show_2.valid?

    # this show is on another streaming network, so it should be valid
    assert show_3.valid?
  end

  test "set_popularity_score for movies" do
    show = Show.create(tmsId: "MV123", stories_count: 1, likes_count: 2, comments_count: 3, awards: [Award.new])
    show.set_popularity_score
    assert_equal -3, show.popularity_score
  end

  test "set_popularity_score for news" do
    show = Show.create(tmsId: "SH123News", seriesId: '123News', stories_count: 1, likes_count: 2, comments_count: 3, awards: [Award.new], genres: ['News'])
    show.set_popularity_score
    assert_equal -17, show.popularity_score
  end

  test "set_popularity_score for series/episodes" do
    series = Show.create(seriesId: 123, tmsId: 'SH1234', stories_count: 5, likes_count: 5, comments_count: 3, awards: [Award.new])
    episode_1 = Show.create(seriesId: 123, tmsId: 'EP123', stories_count: 2, likes_count: 2, comments_count: 2, awards: [Award.new])
    episode_2 = Show.create(seriesId: 123, tmsId: 'EP124', stories_count: 10, likes_count: 10, comments_count: 10, awards: [Award.new])

    # The scores are averaged from all episodes
    [series, episode_1, episode_2].each do |show|
      show.set_popularity_score
      assert_equal 23, show.popularity_score
    end
  end

  test "does not allow paid programs from being imported" do
    show = Show.new(subType: 'Paid Programming')
    refute show.save
    assert "can't be Paid Programming", show.errors[:subType].first
  end

  test "parent program returns parent tv show for episode" do
    parent = Show.create(tmsId: 'SH123', rootId: 123, seriesId: 123)
    show = Show.create(tmsId: 'EP123', seriesId: 123)
    movie = Show.create(tmsId: 'MV123')

    assert_equal parent.id, show.parent_program.id
    assert_equal parent.id, parent.parent_program.id # return itself
    refute movie.parent_program.present? # no parent program
  end

  test "rating percentage is calculated after each rate" do
    @show.rate(@user_1, 'love')
    @show.rate(@user_2, 'like')
    @show.rate(@user_3, 'dislike')

    assert_equal 33.33, @show.rating_percentage_cache['love']
    assert_equal 33.33, @show.rating_percentage_cache['like']
    assert_equal 33.33, @show.rating_percentage_cache['dislike']

    assert_equal 3, @show.cached_votes_total
    assert_equal 1, @show.cached_votes_score
  end
end
