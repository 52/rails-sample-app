module SessionsHelper
  # Login the given user
  def login user
    session[:user_id] = user.id
  end

  # Return the current logged-in user (if any)
  def current_user
    @current_user ||= User.find_by id: session[:user_id]
  end

  # Check if any user logged in?
  def logged_in?
    !session[:user_id].nil?
  end

  # Logout the current user
  def logout
    session.delete :user_id
    @current_user = nil
  end
end
