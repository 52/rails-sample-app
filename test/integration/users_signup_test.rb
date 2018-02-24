require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "successful signup" do
    get signup_path
    assert_difference "User.count", 1 do
      post signup_path,
           params: {user: {name: "New User", email: "newuser@local.com",
                           password:              "123456",
                           password_confirmation: "123456"}}
    end
    follow_redirect!
    assert_template "users/show"
    assert_select ".alert-success"
    assert logged_in?
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
