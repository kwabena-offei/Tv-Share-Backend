require 'test_helper'

class LikesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @like = likes(:one)
    @user = @like.user
    @series_id = '185044'
    @tms_id = 'SH006883590000'
  end

  test "should get index" do
    get likes_url, as: :json, headers: auth_header(@user)
    assert_response :success
  end

  test "should create like" do
    params = {
      seriesId: @series_id,
      liked: true
    }

    VCR.use_cassette("series_#{@series_id}") do
      assert_difference('Like.count', 1) do
        post likes_url, params: params, as: :json, headers: auth_header(@user)
      end
    end

    assert_response 200
  end

  test "should show like" do
    get like_url(@like), as: :json, headers: auth_header(@user)
    assert_response :success
  end

  test "should update like" do
    params = {
      seriesId: @series_id,
      liked: false
    }

    # create a like so we can test that it gets deleted
    show = Show.create(tmsId: @tms_id)
    Like.create(show_id: show.id, user_id: @user.id)

    VCR.use_cassette("series_#{@series_id}") do
      assert_difference('Like.count', -1) do
        post likes_url, params: params, as: :json, headers: auth_header(@user)
      end
    end

    assert_response 200
  end

  test "should destroy like" do
    assert_difference('Like.count', -1) do
      delete like_url(@like), as: :json, headers: auth_header(@user)
    end

    assert_response 204
  end
end
