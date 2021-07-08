require 'test_helper'

class AuthenticationControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create(email: 'test@example.com',
      username: 'example', password: 'password')
  end

  test 'user can login with username' do
    params = {
      username: @user.username,
      password: 'password'
    }
    post auth_login_path, params: params, as: :json
    assert :success
    assert json_response.has_key?('token')
    refute json_response.has_key?('error')
  end

  test 'user can login with email' do
    params = {
      username: @user.email,
      password: 'password'
    }
    post auth_login_path, params: params, as: :json

    assert :success
    assert json_response.has_key?('token')
    refute json_response.has_key?('error')
  end

  test 'user cannot login with invalid password' do
    params = {
      username: @user.username,
      password: 'invalid_password'
    }
    post auth_login_path, params: params, as: :json

    refute json_response.has_key?('token')
    assert json_response.has_key?('error')
    assert :unauthorized
  end

  test 'a user can sign up via Google' do
    social_params = {
      sub: '123',
      email: 'auth@example.com'
    }.as_json
    GoogleAuthVerification.stubs(:verify).returns(social_params)

    assert_difference -> { User.count }, 1 do
      post auth_login_social_url, params: { google_token: '123' }
    end

    assert response.parsed_body.has_key?('token')
    assert response.parsed_body['user'].has_key?('id')
    assert_equal 'auth', response.parsed_body['user']['username']
    assert_equal 'auth@example.com', response.parsed_body['user']['email']
    refute response.parsed_body.has_key?('error')
  end

  test 'a user can log in via Google' do
    @user.update(google_id: '123', email: 'auth@example.com')
    social_params = {
      sub: '123',
      email: 'auth@example.com'
    }.as_json
    GoogleAuthVerification.stubs(:verify).returns(social_params)

    assert_no_difference -> { User.count } do
      post auth_login_social_url, params: { google_token: '123' }
    end

    assert response.parsed_body.has_key?('token')
    assert response.parsed_body['user'].has_key?('id')
    assert_equal 'example', response.parsed_body['user']['username']
    assert_equal 'auth@example.com', response.parsed_body['user']['email']
    refute response.parsed_body.has_key?('error')
  end


  test 'a user can sign up via Facebook' do
    facebook_id = '123'
    facebook_token = 'fbtoken'
    social_data = {
      id: facebook_id,
      email: 'facebook_auth@example.com',
    }.as_json

    facebook_url = "https://graph.facebook.com/v8.0/#{facebook_id}?fields=email,name,picture&access_token=#{facebook_token}"
    HTTParty.stubs(:get).with(facebook_url).returns(social_data)

    assert_difference -> { User.count }, 1 do
      post auth_login_social_url, params: { facebook_id: facebook_id, facebook_token: facebook_token }
    end

    assert response.parsed_body.has_key?('token')
    assert response.parsed_body['user'].has_key?('id')
    assert_equal 'facebook_auth', response.parsed_body['user']['username']
    assert_equal 'facebook_auth@example.com', response.parsed_body['user']['email']
    refute response.parsed_body.has_key?('error')
  end

  test 'a user can log in via Facebook' do
    facebook_id = '123'
    facebook_token = 'fbtoken'
    social_data = {
      id: facebook_id,
      email: 'example@example1.com',
    }.as_json

    @user.update(facebook_id: facebook_id, email: 'auth@example.com')

    facebook_url = "https://graph.facebook.com/v8.0/#{facebook_id}?fields=email,name,picture&access_token=#{facebook_token}"
    HTTParty.stubs(:get).with(facebook_url).returns(social_data)

    assert_no_difference -> { User.count } do
      post auth_login_social_url, params: { facebook_id: facebook_id, facebook_token: facebook_token }
    end

    assert response.parsed_body.has_key?('token')
    assert response.parsed_body['user'].has_key?('id')
    assert_equal 'example', response.parsed_body['user']['username']
    assert_equal 'auth@example.com', response.parsed_body['user']['email']
    refute response.parsed_body.has_key?('error')  end

  test 'when a user has a Facebook account but logs in with a Google account' do
    user = User.create(email: 'auth@example.com', username: 'auth', password: '123456', facebook_id: 123)
    social_params = {
      sub: '123',
      email: user.email
    }.as_json

    GoogleAuthVerification.stubs(:verify).returns(social_params)
    post auth_login_social_url, params: { google_token: '123' }

    assert_response :unauthorized
    assert_equal 'It looks like you have already created a TV Talk account with Facebook. Please return to the login page and sign in with Facebook.', response.parsed_body['error']
  end

  test 'when a user has a Google account but logs in with a Facebook account' do
    user = User.create(email: 'auth@example.com', username: 'auth', password: '123456', google_id: 123)
    facebook_token = 'fbtoken'
    social_data = {
      id: '123',
      email: user.email,
    }.as_json

    facebook_url = "https://graph.facebook.com/v8.0/#{user.facebook_id}?fields=email,name,picture&access_token=#{facebook_token}"
    HTTParty.stubs(:get).with(facebook_url).returns(social_data)

    post auth_login_social_url, params: { facebook_id: user.facebook_id, facebook_token: facebook_token }

    assert_response :unauthorized
    assert_equal 'It looks like you have already created a TV Talk account with Google. Please return to the login page and sign in with Google.', response.parsed_body['error']
  end

  test 'when a user has a traditional account but logs in with a Facebook account' do
    user = User.create(email: 'auth@example.com', username: 'auth', password: '123456')
    social_params = {
      sub: '123',
      email: user.email
    }.as_json

    GoogleAuthVerification.stubs(:verify).returns(social_params)
    post auth_login_social_url, params: { google_token: '123' }

    assert_response :unauthorized
    assert_equal 'It looks like you have already created a TV Talk account using your preferred email address and a unique password. Please return to the login page and log in with your preferred email and unique password. If you have forgotten your password, you can reset it at the login page.', response.parsed_body['error']
  end

  test 'when a user has a traditional account but logs in with a Google account' do
    user = User.create(email: 'auth@example.com', username: 'auth', password: '123456')
    social_params = {
      sub: '123',
      email: user.email
    }.as_json

    GoogleAuthVerification.stubs(:verify).returns(social_params)
    post auth_login_social_url, params: { google_token: '123' }

    assert_equal 'It looks like you have already created a TV Talk account using your preferred email address and a unique password. Please return to the login page and log in with your preferred email and unique password. If you have forgotten your password, you can reset it at the login page.', response.parsed_body['error']
  end

  test 'when a user has a Google account but logs in with an email and password' do
    user = User.create(email: 'auth@example.com', username: 'auth', password: '123456', google_id: 123)
    params = {
      username: user.email,
      password: 'password'
    }
    post auth_login_path, params: params, as: :json

    assert_equal 'It looks like you have already created a TV Talk account with Google. Please return to the login page and sign in with Google.', response.parsed_body['error']
  end

  test 'when a user has a Facebook account but logs in with an email and password' do
    user = User.create(email: 'auth@example.com', username: 'auth', password: '123456', facebook_id: 123)
    params = {
      username: user.email,
      password: 'password'
    }
    post auth_login_path, params: params, as: :json

    assert_equal 'It looks like you have already created a TV Talk account with Facebook. Please return to the login page and sign in with Facebook.', response.parsed_body['error']
  end

  test 'when a user signs up via social login but their derived username exists' do
    social_params = {
      sub: '123',
      email: "#{@user.username}@social.com"
    }.as_json
    GoogleAuthVerification.stubs(:verify).returns(social_params)

    assert_difference -> { User.count }, 1 do
      post auth_login_social_url, params: { google_token: '123' }
    end

    assert response.parsed_body.has_key?('token')
    assert response.parsed_body['user'].has_key?('id')
    assert response.parsed_body['user'].has_key?('username')
    assert_not_equal @user.username, response.parsed_body['user']['username']
    assert_equal "#{@user.username}@social.com", response.parsed_body['user']['email']
    refute response.parsed_body.has_key?('error')
  end
end
