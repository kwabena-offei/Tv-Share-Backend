class CommentsController < ApplicationController
  before_action :get_current_user, only: [:index]
  before_action :authorize_request, only: [:create, :update, :destroy]
  before_action :set_comment, only: [:update, :destroy]

  # GET /comments
  def index
    if params[:tmsId]
      @comments = Comment.includes(:show, :user).where(shows: { tmsId: params[:tmsId] })
      @current_user_liked_ids = get_current_user_liked_comments(@comments)
      @current_user_reply_comment_ids = get_current_user_reply_comments(@comments)
    end
  end

  # GET /comments/1
  def show
    @comment = Comment.includes(:user, :sub_comments, { likes: :user}).order('sub_comments.id DESC').find(params[:id])
  end

  # POST /comments
  def create
    @show = get_show
    @comment = @current_user.comments.new(text: comment_params[:text], show_id: @show.id, images: comment_params[:images])

    if @comment.save
      render :show, status: :ok
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /comments/1
  def update
    if @comment.update(comment_params)
      render json: @comment
    else
      render json: @comment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /comments/1
  def destroy
    @comment.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def get_show
      show = Show.find_by(tmsId: params[:tmsId])
      if show.blank?
        ImportShowJob.perform_now(tmsId: params[:tmsId])
        show = Show.find_by(tmsId: params[:tmsId])
      end
      show
    end

    def get_current_user_liked_comments(comments)
      if @current_user
        @current_user.likes.where(comment_id: comments).order(id: :desc).pluck(:comment_id)
      else
        []
      end
    end

    def get_current_user_reply_comments(comments)
      if @current_user
        @current_user.sub_comments.where(comment_id: comments).order(id: :desc).pluck(:comment_id)
      else
        []
      end
    end

    def set_comment
      @comment = @current_user.comments.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def comment_params
      params.require(:comment).permit(:text, :hashtag, :show_id, images: [])
    end
end
