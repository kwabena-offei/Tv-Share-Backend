require 'test_helper'

class Admin::MatchingControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_matching_index_url
    assert_response :success
  end

end
