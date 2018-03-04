class PasswordResetsController < ApplicationController
  before_action :not_logged_in
  before_action :user, except: [:new]
  before_action :authorized, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @email = params[:email].downcase
    if @user
      @user.forgot_password
      @user.send_password_reset_email
      redirect_to root_url
      flash[:info] = "Please check your email for the password reset link."
    else
      flash.now[:danger] = "Invalid email address."
      render "new"
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add :password, :blank
      render "edit"
    else
      new_password = params.require(:user).permit :password,
                                                  :password_confirmation
      new_password[:password_reset_sent_at] = nil

      if @user.update_attributes new_password
        flash[:success] = "Successfully update new password."
        redirect_to login_url
      else
        render "edit"
      end
    end
  end

  private

  # Retrive user from database by email
  def user
    @user = User.find_by email: params[:email].downcase
  end

  # Only users have valid email and token can reset password
  def authorized
    @token = params[:id]
    return if @user&.authenticated? :password_reset, @token
    flash[:danger] = "Invalid password reset link."
    redirect_to root_url
  end

  # Check expiration of the password reset token
  def check_expiration
    return unless @user.password_reset_expired?
    message = "This password reset request is expired."
    message << " Enter your email below to request a new one."
    flash[:danger] = message
    redirect_to new_password_reset_url
  end
end
