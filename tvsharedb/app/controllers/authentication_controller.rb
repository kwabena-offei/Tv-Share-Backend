class AuthenticationController < ApplicationController
  before_action :authorize_request, except: :login

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

  def verify
    render json: @current_user
  end

  private

  def login_params
    params.permit(:username, :password)
  end
end
