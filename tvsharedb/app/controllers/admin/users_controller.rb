class Admin::UsersController < AdminController
  skip_before_action :verify_authenticity_token
  before_action :set_user, only: [:update, :destroy]

  def index
    @users = User.order(id: :desc).page(params[:page])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)
    @user.is_robot = true

    if @user.save
      render 'users/show'
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private

  # Only allow a list of trusted parameters through.
  def user_params
    params.require(:user).permit(:username, :name, :password, :email, :image)
  end
end
