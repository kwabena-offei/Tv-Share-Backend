require 'test_helper'

class SubCommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @comment = comments(:one)
    @sub_comment = sub_comments(:one)
  end

  test "should get index" do
    get sub_comments_url, as: :json
    assert_response :success
  end

  test "should create sub_comment" do
    assert_difference('SubComment.count') do
      post sub_comments_url, params: {
        sub_comment: {
          comment_id: @comment.id,
          text: @comment.text,
          user_id: @comment.user_id
          }
        },
        headers: auth_header(@comment.user), as: :json
    end

    assert_response 201
  end

  test "should show sub_comment" do
    get sub_comment_url(@sub_comment), as: :json
    assert_response :success
  end

  test "should update sub_comment" do
    patch sub_comment_url(@sub_comment), params: {
      sub_comment: {
        comment_id: @sub_comment.comment_id,
        hashtag: @sub_comment.hashtag,
        text: @sub_comment.text,
        user_id: @sub_comment.user_id
        }
      },
      headers: auth_header(@comment.user), as: :json
    assert_response 200
  end

  test "should destroy sub_comment" do
    assert_difference('SubComment.count', -1) do
      delete sub_comment_url(@sub_comment), as: :json
    end

    assert_response 204
  end
end
