class SearchController < ApplicationController
  before_action :authenticate_user!

  def users
    @page_title = 'Search'
    if params[:q].present?
      term = "%#{params[:q]}%"
      @users = User.where('username ILIKE ? OR name ILIKE ?', term, term).where.not(id: current_user.id)
    else
      @users = []
    end
  end
end
