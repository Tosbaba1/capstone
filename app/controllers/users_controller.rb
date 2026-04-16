class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: %i[show followers following library]

  def show
    @page_title = @user.name
    allowed = allowed_to_view_user?(@user)
    @restricted = !allowed
    @posts = allowed ? @user.posts.order(created_at: :desc) : []
  end

  def followers
    unless allowed_to_view_user?(@user)
      redirect_to user_path(@user), alert: "Not authorized to view followers."
      return
    end

    @followers = @user.followers
    @requests = @user.receivedfollowrequests.where(status: 'pending')
    @page_title = "Followers"
  end

  def following
    unless allowed_to_view_user?(@user)
      redirect_to user_path(@user), alert: "Not authorized to view following."
      return
    end

    @following = @user.following
    @requests = @user.sentfollowrequests.where(status: 'pending')
    @page_title = "Following"
  end

  def library
    unless allowed_to_view_user?(@user)
      redirect_to user_path(@user), alert: private_library_message
      return
    end

    @page_title = library_page_title
    @active_tab = normalized_library_tab
    scope = @user.readings.includes(:book)

    if @user == current_user
      scope = scope.where(is_private: true) if @active_tab == 'private'
      scope = scope.where(is_private: false) if @active_tab == 'public'
    else
      scope = scope.where(is_private: false)
    end

    @reading_now  = scope.where(status: 'reading')
    @want_to_read = scope.where(status: 'want_to_read')
    @finished     = scope.where(status: 'finished')

    render template: 'pages/library'
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def allowed_to_view_user?(user)
    user == current_user || !user.is_private? || current_user.following.exists?(id: user.id)
  end

  def library_page_title
    @user == current_user ? "Library" : "#{@user.name}'s Library"
  end

  def normalized_library_tab
    return "public" unless @user == current_user

    %w[public private ai].include?(params[:tab]) ? params[:tab] : "public"
  end

  def private_library_message
    "This library is private. Follow #{@user.name} to view their public shelf."
  end
end
