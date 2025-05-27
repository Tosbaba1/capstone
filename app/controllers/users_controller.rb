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

  def library
    @user = User.find(params[:id])
    allowed = @user == current_user || !@user.is_private || current_user.following.include?(@user)
    unless allowed
      redirect_to user_path(@user), alert: 'Not authorized to view library.' and return
    end

    @page_title = "#{@user.name}'s Library"
    @active_tab = params[:tab] || 'public'
    scope = @user.readings.includes(:book)

    if @user == current_user
      scope = scope.where(is_private: true) if @active_tab == 'private'
      scope = scope.where(is_private: false) if @active_tab == 'public'
    else
      scope = scope.where(is_private: false)
      @active_tab = 'public'
    end

    @reading_now  = scope.where(status: 'reading')
    @want_to_read = scope.where(status: 'want_to_read')
    @finished     = scope.where(status: 'finished')

    render template: 'pages/library'
  end
end
