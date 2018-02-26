class UsersController < ApplicationController
  before_action :retrive_user, except: [:new, :create]
  before_action :logged_in_user, only: [:index, :edit, :update]
  before_action :authorize, only: [:edit, :update]

  def index
    @users = User.paginate page: params[:page]
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      login @user
      remember @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render "new"
    end
  end

  def show
    @user = User.find_by id: params[:id]
  end

  def edit
  end

  def update
    if @user.update_attributes user_params
      flash[:success] = "Successfully updated your information"
      redirect_to @user
    else
      render "edit"
    end
  end

  private

  def user_params
    params.require(:user).permit :name,     :email,
                                 :password, :password_confirmation
  end

  # Get the corresponded user from the id in URL
  def retrive_user
    @user = User.find_by id: params[:id]
  end

  # Confirm that user is logged in
  def logged_in_user
    return if logged_in?
    flash[:danger] = "Please login."
    store_location # Store current url in session before redirect to login page
    redirect_to login_url
  end

  # Confirm the correct user
  def authorize
    return if current_user?(@user)
    flash[:danger] = "You are not authorized to perform this action."
    redirect_to root_url
  end
end
