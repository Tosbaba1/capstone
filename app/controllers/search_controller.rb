class SearchController < ApplicationController
  before_action :authenticate_user!

  def users
    @page_title = 'Search'
    @recent_searches = current_user.search_histories.order(created_at: :desc).limit(5)

    if params[:q].present?
      term = "%#{params[:q]}%"
      @users = User.where('username ILIKE ? OR name ILIKE ?', term, term).where.not(id: current_user.id)
      current_user.search_histories.create(query: params[:q])
    else
      @users = []
    end
  end
end
