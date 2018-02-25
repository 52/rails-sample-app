module SessionsHelper
  # Login the given user
  def login user
    session[:user_id] = user.id
  end

  # Return the current logged-in user (if any)
  def current_user
    if user_id = session[:user_id]
      @current_user ||= User.find_by id: user_id
    elsif user_id = cookies.signed[:user_id]
      user = User.find_by id: user_id
      if user&.authenticated? cookies[:remember_token]
        login user
        @current_user = user
      end
    end
  end

  # Check if any user logged in?
  def logged_in?
    !current_user.nil?
  end

  # Logout the current user
  def logout
    session.delete :user_id
    forget @current_user
    @current_user = nil
  end

  # Remember user when user chooses "remember me" login option
  def remember user
    # Create and save a token in database
    user.remember
    # Save user id and token in cookies
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Forget a persistent session (delete "remember me" info)
  def forget user
    # Reset remember token in db to nil (if any)
    user.forget
    # Delete info store in cookies
    cookies.delete :user_id
    cookies.delete :remember_token
  end
end
