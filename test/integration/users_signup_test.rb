require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
  end

  test "successful signup" do
    get signup_path
    assert_difference "User.count", 1 do
      post signup_path,
           params: {user: {name: "New User", email: "newuser@local.com",
                           password:              "123456",
                           password_confirmation: "123456"}}
    end

    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns :user
    assert_not user.activated?

    # Try to login before activation
    login_as user
    assert_not logged_in?

    # Try to activate with wrong email
    get edit_account_activation_url(user.activation_token, email: "wrong")
    assert_not user.reload.activated?

    # Try to activate with wrong token
    get edit_account_activation_url("wrong", email: user.email)
    assert_not user.reload.activated?

    # Activate with valid activation link
    get edit_account_activation_url(user.activation_token, email: user.email)
    assert user.reload.activated?
    assert logged_in?
    assert_redirected_to user
    assert flash[:success]
  end

  test "invalid user signup" do
    get signup_path
    assert_no_difference "User.count" do
      post signup_path,
           params: {user: {name: "Jane", email: "jane@local",
                           password:              "123456",
                           password_confirmation: "123456"}}
    end
    assert_template "users/new"
  end

  test "invalid email error messages" do
    post signup_path,
         params: {user: {name: "Jane", email: "jane@local",
                         password:              "123456",
                         password_confirmation: "123456"}}
    assert_select "#error_explanation ul li", "Email is invalid"
  end

  test "password is too short error messages" do
    post signup_path,
         params: {user: {name: "Jane", email: "jane@local.com",
                         password:              "123",
                         password_confirmation: "123"}}
    assert_select "#error_explanation ul li",
                  "Password is too short (minimum is 6 characters)"
  end
end
