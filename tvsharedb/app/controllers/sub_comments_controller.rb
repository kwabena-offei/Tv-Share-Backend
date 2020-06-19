class SubCommentsController < ApplicationController
  before_action :set_sub_comment, only: [:show, :update, :destroy]

  # GET /sub_comments
  def index
    @sub_comments = SubComment.all

    render json: @sub_comments
  end

  # GET /sub_comments/1
  def show
    render json: @sub_comment
  end

  # POST /sub_comments
  def create
    @sub_comment = SubComment.new(sub_comment_params)

    if @sub_comment.save
      render json: @sub_comment, status: :created, location: @sub_comment
    else
      render json: @sub_comment.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /sub_comments/1
  def update
    if @sub_comment.update(sub_comment_params)
      render json: @sub_comment
    else
      render json: @sub_comment.errors, status: :unprocessable_entity
    end
  end

  # DELETE /sub_comments/1
  def destroy
    @sub_comment.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_sub_comment
      @sub_comment = SubComment.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def sub_comment_params
      params.require(:sub_comment).permit(:text, :hashtag, :comment_id, :user_id, :images)
    end
end
