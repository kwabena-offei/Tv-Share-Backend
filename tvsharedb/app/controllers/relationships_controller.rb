class RelationshipsController < ApplicationController
  before_action :authorize_request

  def index
    @current_user
  end

  def create
    followed_user = User.find(params[:followed_id])
    
    @relationship = @current_user.active_relationships.build(followed_id: followed_user.id)
    
    if @relationship.save
      render json: { success: true, followers_count: followed_user.followers_count }, status: :created
    else
      render json: { error: @relationship.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    followed_user = User.find(params[:id])
    @relationship = @current_user.active_relationships.find_by(followed_id: followed_user.id)
    
    if @relationship
      @relationship.destroy
      render json: { success: true, followers_count: followed_user.followers_count }, status: :ok
    else
      render json: { error: 'Relationship not found' }, status: :not_found
    end
  end
end