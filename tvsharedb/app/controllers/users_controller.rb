class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]
  before_action :authorize_request, only: [:update, :destroy]

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    render json: @user
  end

  # POST /users
  def create
    @user = User.new(user_params)
    if @user.save
      @token = encode({ user_id: @user.id, username: @user.username })
      render json: { user: @user, token: @token }, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  def location
    render json: request.location.postal_code
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      if params[:username]
        @user = User.find_by(username: params[:username])
      else
        @user = User.find(params[:id])
      end
    end

    # Only allow a trusted parameter "white list" through.
    def user_params
      params.permit(:username, :bio, :password, :password_digest, :zipcode, :email, :gender, :cable_provider, :birth_date, :image, :bio, :city, :phone_number, :streaming_service, :name)
    end
end
