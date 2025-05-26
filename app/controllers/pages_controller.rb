class PagesController < ApplicationController
  def library
    @page_title = "Library"
  end

  def notifications
    @page_title = "Notifications"
  end

  def profile
    @page_title = "Profile"
  end
end
