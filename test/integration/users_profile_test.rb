require "test_helper"

class UsersProfileTest < ActionDispatch::IntegrationTest
  def setup
    @user = users :michael
  end

  test "profile display" do
    get user_path @user
    assert_template "users/show"
    assert_select "h1>img.gravatar"

    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end
end
