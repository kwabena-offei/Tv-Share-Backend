class AuthenticationController < ApplicationController
  before_action :authorize_request, except: [:login, :login_social]

  def login
    if login_params[:username]&.include?('@')
      @user = User.find_by(email: login_params[:username])
    else
      @user = User.find_by(username: login_params[:username])
    end

    if @user.present? && @user.authenticate(login_params[:password]) #authenticate method provided by Bcrypt and 'has_secure_password'
      token = encode(user_id: @user.id, username: @user.username)
      render json: { token: token , user: @user}, status: :ok
    else
      render json: { error: 'unauthorized' }, status: :unauthorized
    end
  end

  def login_social
    if params[:google_token]
      social_data = GoogleAuthVerification.verify(params[:google_token])
      google_id = social_data.dig('sub')
      @user = User.find_or_initialize_by(google_id: google_id)

      unless @user.persisted?
        @user.email = social_data.dig('email')
        @user.image = social_data.dig('picture')
        @user.username = social_data.dig('email')&.split('@')&.first
        @user.password = SecureRandom.gen_random(64) # random password
        @user.save
      end
    end

    if @user.persisted?
      token = encode(user_id: @user.id, username: @user.username)
      render json: { token: token , user: @user}, status: :ok
    else
      render json: { error: 'unauthorized' }, status: :unauthorized
    end
  end

  def verify
    render json: @current_user
  end

  private

  def login_params
    params.permit(:username, :password)
  end
end
#
# create_table "users", force: :cascade do |t|
#   t.string "username"
#   t.string "email"
#   t.string "password_digest"
#   t.integer "zipcode"
#   t.datetime "created_at", precision: 6, null: false
#   t.datetime "updated_at", precision: 6, null: false
#   t.string "gender"
#   t.string "cable_provider"
#   t.string "birth_date"
#   t.text "image"
#   t.text "bio"
#   t.string "city"
#   t.string "phone_number"
#   t.string "streaming_service"
#   t.string "google_id"
#   t.string "facebook_id"
#   t.index ["facebook_id"], name: "index_users_on_facebook_id", unique: true
#   t.index ["google_id"], name: "index_users_on_google_id", unique: true
