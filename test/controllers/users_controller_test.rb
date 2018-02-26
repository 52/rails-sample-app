require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @admin       = users :admin
    @normal_user = users :normal_user
    @michael     = users :michael
  end

  test "should get new" do
    get signup_url
    assert_response :success
  end

  test "only logged in users can see list of users" do
    get users_path
    assert_redirected_to login_path
  end

  test "should not allow the admin attribute to be edited via the web" do
    login_as @normal_user
    assert_not @normal_user.admin?
    update_user @normal_user, admin: true
    assert_not @normal_user.admin?
  end

  test "non-admin users can't delete other users" do
    login_as @normal_user
    assert_no_difference "User.count" do
      delete user_path(@michael)
    end
    assert_redirected_to root_url
    assert_not_empty flash[:danger]
  end

  test "admin successfully delete normal users" do
    login_as @admin
    assert_difference "User.count", -1 do
      delete user_path(@michael)
    end
    assert_redirected_to users_path
    assert_not_empty flash[:success]
  end
end
