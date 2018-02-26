require "test_helper"

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin       = users :admin
    @normal_user = users :normal_user
  end

  test "users index page must have pagination" do
    login_as @normal_user
    get users_path
    assert_template "users/index"
    assert_select "div.pagination"
    User.paginate(page: 1).each do |user|
      assert_select "a[href=?]", user_path(user), text: user.name
    end
  end

  test "don't show delete link to normal user" do
    login_as @normal_user
    get users_path
    assert_select "a", text: "delete", count: 0
  end

  test "show delete link to admin" do
    login_as @admin
    get users_path
    User.paginate(page: 1).each do |user|
      unless user.admin?
        assert_select "a[href=?]", user_path(user), text: "delete"
      end
    end
  end
end
