require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new name: "Example", email: "example@local.com",
                     password: "foobar", password_confirmation: "foobar"
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = ""
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = ""
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 200 + "@local.com"
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w(user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn)
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w(user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com foo@bar..com)
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    dupicate_user = @user.dup
    dupicate_user.email.upcase!
    @user.save
    assert_not dupicate_user.valid?
  end

  test "email addresses should be saved as lowercase" do
    mixed_case_email = "mIXcAsE@lOcAl.cOM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.email
  end

  test "password shouldn't be blank" do
    @user.password = @user.password_confirmation = " " * 6
    @user.save
    assert_not @user.valid?
  end

  test "password should be at least 6 characters" do
    @user.password = @user.password_confirmation = "a" * 5
    @user.save
    assert_not @user.valid?
  end

  test "associated microposts should be destroyed when delete user" do
    @user.save
    @user.microposts.create content: "Lorem"
    assert_difference "Micropost.count", -1 do
      @user.destroy
    end
  end

  test "should follow and unfollow other user" do
    michael  = users :michael
    hijacker = users :hijacker

    assert_not michael.following? hijacker

    michael.follow hijacker
    assert michael.following? hijacker
    assert hijacker.followers.include? michael

    michael.unfollow hijacker
    assert_not michael.following? hijacker
  end
end
