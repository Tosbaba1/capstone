class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:id])
    @page_title = @user.name
    allowed = @user == current_user || !@user.is_private || current_user.following.include?(@user)
    @restricted = !allowed
    @posts = allowed ? @user.posts.order(created_at: :desc) : []
  end

  def followers
    @user = User.find(params[:id])
    allowed = @user == current_user || !@user.is_private || current_user.following.include?(@user)
    unless allowed
      redirect_to user_path(@user), alert: 'Not authorized to view followers.' and return
    end
    @followers = @user.followers
    @requests = @user.receivedfollowrequests.where(status: 'pending')
    @page_title = "Followers"
  end

  def following
    @user = User.find(params[:id])
    allowed = @user == current_user || !@user.is_private || current_user.following.include?(@user)
    unless allowed
      redirect_to user_path(@user), alert: 'Not authorized to view following.' and return
    end
    @following = @user.following
    @requests = @user.sentfollowrequests.where(status: 'pending')
    @page_title = "Following"
  end
end
