require "test_helper"

class UserUpdateTest < ActionDispatch::IntegrationTest
  def setup
    @user = users :michael
    @hijacker = users :hijacker
  end
  test "user must login to update profile" do
    get edit_user_path(@user)
    assert_redirected_to login_url
    assert_not_empty flash[:danger]
  end

  test "user must be authorized to update profile" do
    login_as @hijacker

    get edit_user_path(@user)
    assert_redirected_to root_url
    assert_not_empty flash[:danger]

    new_name  = "Hijacked"
    new_email = "hijacked@example.com"
    update_user @user, name: new_name, email: new_email
    @user.reload
    assert_not_equal new_name, @user.name
    assert_not_equal new_email, @user.email
    assert_redirected_to root_url
    assert_not_empty flash[:danger]
  end

  test "update user with invalid information" do
    login_as @user
    get edit_user_path(@user)
    assert_template "users/edit"

    update_user @user, name: ""
    assert_template "users/edit"
    assert_select "#error_explanation"
  end

  test "update user with valid information" do
    login_as @user
    new_name  = "Michael Phelp"
    new_email = "michaelphelp@example.com"
    update_user @user, name: new_name, email: new_email
    @user.reload
    assert_equal new_name, @user.name
    assert_equal new_email, @user.email
    assert_redirected_to user_path(@user)
    follow_redirect!
    assert_not_empty flash[:success]
  end
end
