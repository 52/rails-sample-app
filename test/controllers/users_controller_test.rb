require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get signup_url
    assert_response :success
  end

  test "only logged in users can see list of users" do
    get users_path
    assert_redirected_to login_path
  end
end
