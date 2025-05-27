class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    @page_title = 'Search'
    @active_tab = params[:tab] || 'users'

    if @active_tab == 'books'
      if params[:q].present?
        @external_books = OpenLibraryClient.search_books(params[:q])
      else
        @external_books = { 'docs' => [] }
      end
    else
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
