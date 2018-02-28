class SessionsController < ApplicationController
  def new
    redirect_to root_path if logged_in?
  end

  def create
    user = User.find_by email: params[:session][:email].downcase
    if user&.authenticate(params[:session][:password])
      if user.activated?
        login user
        params[:session][:remember_me] == "1" ? remember(user) : forget(user)
        flash[:success] = "Logged in!"
        redirect_back_or user
      else
        flash[:warning] = "Account not activated. Check email to activate."
        redirect_to root_url
      end
    else
      flash.now[:danger] = "Invalid email/password combination."
      render "new"
    end
  end

  def destroy
    logout if logged_in?
    redirect_to root_url
  end
end
