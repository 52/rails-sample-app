require "test_helper"

class MicropostsIntefaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users :michael
  end

  test "microposts interface" do
    login_as @user
    get root_path

    # Invalid submission
    assert_no_difference "Micropost.count" do
      post microposts_path, params: {micropost: {content: ""}}
    end
    assert_select "div#error_explanation"

    # Valid submission
    content = "This micropost really ties the room together"
    assert_difference "Micropost.count", 1 do
      post microposts_path, params: {micropost: {content: content}}
    end
    follow_redirect!
    assert_match content, response.body

    # Delete post
    assert_select "a", text: "delete"
    micropost = @user.microposts.paginate(page: 1).first
    assert_difference "Micropost.count", -1 do
      delete micropost_path(micropost)
    end

    # Visit different user, no delete links
    get user_path users(:admin)
    assert_select "a", text: "delete", count: 0
  end
end
