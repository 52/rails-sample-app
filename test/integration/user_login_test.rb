require "test_helper"
class UserLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users :michael
  end

  test "flash message must disapear when redirect after login failed" do
    get login_path
    assert_template "sessions/new"
    post login_path, params: {session: {email: "", password: ""}}
    assert_template "sessions/new"
    assert_select ".alert-danger", count: 1
    get root_path
    assert_select ".alert-danger", count: 0
  end

  test "login successful with valid information" do
    get login_path
    post login_path, params: {session: {email:    @user.email,
                                        password: "123456"}}
    assert_redirected_to @user
    follow_redirect!
    assert_template "users/show"
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end

  test "login with remembering" do
    login_as @user, remember_me: "1"
    assert_not_empty cookies[:remember_token]
  end

  test "login without remembering" do
    login_as @user, remember_me: "0"
    assert cookies[:remember_token].nil?
  end
end
