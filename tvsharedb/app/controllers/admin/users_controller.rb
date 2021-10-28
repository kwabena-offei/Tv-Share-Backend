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

    if @user.save
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    @user.assign_attributes(user_params)
    shows = Show.where(tmsId: params[:tmsIds])
    update_show_positions if params[:tmsIds].present?

    if @user.save
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    def update_show_positions
      shows = Show.where(tmsId: params[:tmsIds])

      params[:tmsIds].each do |tmsId|
        if shows.none? { |show| show.tmsId == tmsId }
          ImportShowJob.perform_now(tmsId: tmsId)
          shows = Show.where(tmsId: params[:tmsIds])
        end
      end

      shows = Show.where(tmsId: params[:tmsIds])
      position_map = params[:tmsIds].each_with_object({}).with_index do |(tmsId, memo), index|
        memo[tmsId] = index
      end

      @user.show_users.destroy_all
      @user.show_users = shows.map.with_index do |show, index|
        cs = ShowUser.new(user_id: @user.id, show_id: show.id)
        cs.position = position_map[show.tmsId]
        cs
      end
    end

    # Only allow a list of trusted parameters through.
    def user_params
      params.require(:user).permit(:title, :active, :position)
    end
end
