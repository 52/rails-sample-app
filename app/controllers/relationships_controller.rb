class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    @user = User.find(params[:followed_id])
    current_user.follow(@user)
    respond_to do |format|
      format.html{redirect_to @user}
      format.js
    end
  end

  def destroy
    relationship = Relationship.find_by id: params[:id]
    @user = relationship.followed
    relationship&.destroy
    respond_to do |format|
      format.html{redirect_back fallback_location: root_url}
      format.js
    end
  end
end
