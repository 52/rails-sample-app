require "test_helper"

class PasswordResetTest < ActionDispatch::IntegrationTest
  def setup
    @user = users :michael
    ActionMailer::Base.deliveries.clear
  end

  test "password reset" do
    # Login page has "forgot password?" link
    get login_path
    assert_select "a[href=?]", new_password_reset_path

    get new_password_reset_path
    assert_template "password_resets/new"

    # Submit invalid email address
    post password_resets_path, params: {email: "invalid@local.com"}
    assert_template "password_resets/new"
    assert flash[:danger]

    # Receive instruction email when submit valid email address
    post password_resets_path params: {email: @user.email}
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_redirected_to root_url
    assert flash[:info]

    user = assigns :user

    # Reset link with wrong email address
    get edit_password_reset_url(user.password_reset_token, email: "wrong")
    assert_redirected_to root_url
    assert flash[:danger]

    # Reset link with wrong token
    get edit_password_reset_url("wrong_token", email: user.email)
    assert_redirected_to root_url
    assert flash[:danger]

    # Expired reset link
    user.update_attribute :password_reset_sent_at, 3.hours.ago
    get edit_password_reset_url(user.password_reset_token, email: user.email)
    assert_redirected_to new_password_reset_url
    assert flash[:danger]

    # Unexpired reset link with valid email address and token
    user.update_attribute :password_reset_sent_at, Time.zone.now
    get edit_password_reset_url(user.password_reset_token, email: user.email)
    assert_template "password_resets/edit"

    # Submit empty new password
    update_password user
    assert_select "div#error_explanation"

    # Submit invalid password and confirmation
    update_password user, "123456", "qwerty"
    assert_select "div#error_explanation"

    # Submit valid new password and confirmation
    new_pwd = "qwerty"
    update_password user, new_pwd, new_pwd
    assert flash[:success]
    assert BCrypt::Password.new(user.reload.password_digest).is_password? new_pwd
  end
end
