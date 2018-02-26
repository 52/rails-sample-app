require "test_helper"

class FriendlyForwardingTest < ActionDispatch::IntegrationTest
  def setup
    @user = users :michael
  end

  test "friendly forwarding" do
    get edit_user_path(@user)
    login_as @user
    assert_redirected_to edit_user_path(@user)
  end
end
