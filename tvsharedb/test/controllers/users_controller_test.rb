require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
  end

  test "should create user" do
    assert_difference('User.count') do
      post users_url, params: { email: @user.email, password_digest: @user.password_digest, username: @user.username, zipcode: @user.zipcode }, as: :json
    end

    assert_response 201
  end

  test "should show user" do
    get user_url(@user), as: :json
    assert_response :success
  end

  test "should update user" do
    patch user_url(@user), params: { email: @user.email, password_digest: @user.password_digest, username: @user.username, zipcode: @user.zipcode }, as: :json, headers: auth_header(@user)
    assert_response 200
  end
end
