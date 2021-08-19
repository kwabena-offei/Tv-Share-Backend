require 'test_helper'

class Shows::RatingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @show = shows(:one)
    @user = users(:one)
  end

  test "when rating with tmsId" do
    Show.any_instance.expects(:rate).with(@user, 'love').once

    post show_ratings_url(@show.tmsId), as: :json, params: {
      rating: 'love'
    }, headers: auth_header(@user)

    assert_response :success
    assert response.parsed_body.has_key?('like')
    assert response.parsed_body.has_key?('love')
    assert response.parsed_body.has_key?('dislike')
  end

  test "when rating with id" do
    Show.any_instance.expects(:rate).with(@user, 'like').once
    post show_ratings_url(@show.id), as: :json, params: {
      rating: 'like'
    }, headers: auth_header(@user)

    assert_response :success
    assert response.parsed_body.has_key?('like')
    assert response.parsed_body.has_key?('love')
    assert response.parsed_body.has_key?('dislike')
  end

  test "when rating a show that has already been rated tmsId" do
    post show_ratings_url(@show.tmsId), as: :json, params: {
      rating: 'love'
    }, headers: auth_header(@user)

    assert_response :success
    assert_equal 100.00, response.parsed_body['love']
    assert_equal 0.00,   response.parsed_body['like']
    assert_equal 0.00,   response.parsed_body['dislike']

    post show_ratings_url(@show.tmsId), as: :json, params: {
      rating: 'like'
    }, headers: auth_header(@user)

    assert_response :success
    @show.reload
    assert_equal 100.00, response.parsed_body['like']
    assert_equal 0.00,   response.parsed_body['love']
    assert_equal 0.00,   response.parsed_body['dislike']
  end

  test "when rating with missing parameters" do
    Show.any_instance.expects(:rate).never

    post show_ratings_url(@show.tmsId), as: :json, params: {}, headers: auth_header(@user)
    assert_response :not_acceptable
  end
end
