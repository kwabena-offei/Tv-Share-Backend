class AuthenticationController < ApplicationController
  def login
    @user = User.find_by_username(params[:username])
    if @user.authenticate(params[:password]) #authenticate method provided by Bcrypt and 'has_secure_password'
      token = encode(user_id: @user.id, username: @user.username)
      render json: { token: token }, status: :ok
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
