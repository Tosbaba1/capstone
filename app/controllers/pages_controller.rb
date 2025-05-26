class PagesController < ApplicationController
  def library
    @page_title = "Library"
    @books = current_user.books.distinct
  end

  def notifications
    @page_title = "Notifications"
    @notifications = current_user.notifications.order(created_at: :desc)
  end

  def profile
    @page_title = "Profile"
  end
end
