require 'test_helper'

class ShowsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @show = shows(:one)
  end

  test "should get index" do
    get shows_url, as: :json
    assert_response :success
  end

  test "should create show" do
    assert_difference('Show.count') do
      post shows_url, params: { show: {  } }, as: :json
    end

    assert_response 201
  end

  test "should show show" do
    get show_url(@show), as: :json
    assert_response :success
  end

  test "should update show" do
    patch show_url(@show), params: { show: {  } }, as: :json
    assert_response 200
  end

  test "should destroy show" do
    assert_difference('Show.count', -1) do
      delete show_url(@show), as: :json
    end

    assert_response 204
  end
end
