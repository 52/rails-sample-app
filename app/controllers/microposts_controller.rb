class MicropostsController < ApplicationController
  before_action :logged_in_user

  def create
    @micropost = current_user.microposts.build micropost_params
    if @micropost.save
      flash[:success] = "Micropost created"
      redirect_to root_url
    else
      # @feed_items = current_user.feed.paginate(page: params[:page])
      @feed_items = []
      render "static_pages/home"
    end
  end

  def destroy
    @micropost = current_user.microposts.find_by id: params[:id]
    if @micropost&.destroy
      flash[:success] = "Micropost deleted!"
      redirect_to request.referrer || root_url
      # redirect_back fallback_location: root_url
    else
      redirect_to root_url
    end
  end

  private

  def micropost_params
    params.require(:micropost).permit :content, :picture
  end
end
