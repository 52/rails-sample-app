class ApplicationController < ActionController::Base
  include SessionsHelper
  protect_from_forgery with: :exception

  private

  # Before filters

  # Confirm that user is logged in
  def logged_in_user
    return if logged_in?
    flash[:danger] = "Please login."
    store_location # Store current url in session before redirect to login page
    redirect_to login_url
  end

  # Prevent already logged-in user from performing some actions like signup,.etc
  def not_logged_in
    redirect_to root_url if logged_in?
  end
end
