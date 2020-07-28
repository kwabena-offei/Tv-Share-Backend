class LikesController < ApplicationController
  before_action :set_like, only: [:show, :update, :destroy]
  before_action :authorize_request

  # GET /likes
  def index
    @likes = get_likes
    render json: @likes
  end

  # GET /likes/1
  def show
    render json: @like
  end

  # POST /likes
  # This is currently designed for liking "shows".
  # This will need to be refactored to accomodate liking comments, etc.
  def create
    # If the tmsId begins with SH or MV, we can use it directly
    # If the tmsId beings with EP, we need to find its root tmsId
    # The reason being users like shows, not episodes
    if params[:tmsId].match(/SH|MV/)
      show = Show.find_by(tmsId: params[:tmsId])
    end

    if show.blank?
      if params[:tmsId].match(/SH|MV/)
        import_options = { tmsId: params[:tmsId] }
      else
        import_options = { seriesId: params[:seriesId] }
      end

      ImportShowJob.perform_now(import_options)
      show = Show.find_by(import_options)
    end

    @like = @current_user.likes.find_or_initialize_by(show_id: show.id)

    if params[:liked]
      # create like, unless it exists
      @like.save
    else
      # delete like, if it exists
      @like.destroy if @like.persisted?
    end

    @likes = get_likes
    render json: @likes
  end

  # PATCH/PUT /likes/1
  def update
    if @like.update(like_params)
      render json: @like
    else
      render json: @like.errors, status: :unprocessable_entity
    end
  end

  # DELETE /likes/1
  def destroy
    @like.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_like
      @like = Like.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def like_params
      params.require(:like).permit(:like, :user_id, :comment_id, :show_id, :sub_comment_id)
    end

    def get_likes
      @current_user.likes.for_shows.includes(:show).flat_map do |like|
        [like.show.tmsId, like.show.seriesId]
      end.compact
    end
end
