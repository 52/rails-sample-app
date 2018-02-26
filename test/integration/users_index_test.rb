require "test_helper"

class UsersIndexTest < ActionDispatch::IntegrationTest
  test "users index page must have pagination" do
    login_as users(:michael)
    get users_path
    assert_template "users/index"
    assert_select "div.pagination"
    User.paginate(page: 1) do |user|
      assert_select "a[href=?]", user_path(user), text: user.name
    end
  end
end
