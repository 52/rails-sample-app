class UsersController < ApplicationController
  before_action :retrive_user, except: [:new, :create]
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy,
                                        :following, :followers]
  before_action :authorize, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]
  before_action :not_logged_in, only: [:new, :create]

  def index
    @users = User.where(activated: true).paginate page: params[:page]
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new user_params
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render "new"
    end
  end

  def show
    @user = User.find_by id: params[:id]
    redirect_to root_url unless @user.activated?
    @microposts = @user.microposts.paginate page: params[:page]
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

  def destroy
    flash[:success] = "Successfully deleted #{@user.name}'s account."
    @user.destroy
    redirect_to users_path
  end

  def following
    @title = "Following"
    @users = @user.following.paginate page: params[:page]
    render "show_follow"
  end

  def followers
    @title = "Followers"
    @users = @user.followers.paginate page: params[:page]
    render "show_follow"
  end

  private

  def user_params
    params.require(:user).permit :name,     :email,
                                 :password, :password_confirmation
  end

  # Before filters

  # Get the corresponded user from the id in URL
  def retrive_user
    @user = User.find_by id: params[:id]
  end

  # Confirm the correct user
  def authorize
    return if current_user?(@user)
    flash[:danger] = "You are not authorized to perform this action."
    redirect_to root_url
  end

  # Confirm currently logged-in user is admin
  def admin_user
    return if current_user.admin?
    flash[:danger] = "Only admin can perform this action"
    redirect_to root_url
  end
end
