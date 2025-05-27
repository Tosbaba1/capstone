class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    @user = User.find(params[:id])
    @page_title = @user.name
    @posts = @user.posts.order(created_at: :desc)
  end
end
