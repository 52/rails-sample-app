require File.expand_path("../../config/environment", __FILE__)
require "rails/test_help"

require "minitest/reporters"
Minitest::Reporters.use!

DEFAULT_TEST_PASSWORD = "123456".freeze

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml
  # for all tests in alphabetical order.
  fixtures :all

  def logged_in?
    !session[:user_id].nil?
  end

  # Login as a particular user
  # This helper is available for controller tests
  def login_as user
    session[:user_id] = user.id
  end
end

class ActionDispatch::IntegrationTest
  # Login as a particular user
  # This helper is available for integration test
  def login_as user, password: DEFAULT_TEST_PASSWORD, remember_me: "1"
    post login_path, params: {session: {email:       user.email,
                                        password:    password,
                                        remember_me: remember_me}}
  end

  # Update the given user
  def update_user(user, name: nil, email: nil, password: DEFAULT_TEST_PASSWORD,
                  admin: nil)
    name     ||= user.name
    email    ||= user.email
    password ||= user.password
    admin    ||= user.admin
    patch user_path(user), params: {user: {name: name, email: email,
                                           password: password,
                                           password_confirmation: password,
                                           admin: admin}}
  end
end
