require "test_helper"

class SessionsHelperTest < ActionView::TestCase
  def setup
    @user = users :michael
  end

  # Test `current_user` helper method
  test "current_user return right user when session is nil" do
    remember @user
    assert_equal @user, current_user
  end
end
