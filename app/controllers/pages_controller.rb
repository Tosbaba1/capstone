class PagesController < ApplicationController
  def library
    @page_title = "Library"
    @readings = current_user.readings.includes(:book)
  end

  def notifications
    @page_title = "Notifications"
    scope = current_user.notifications.order(created_at: :desc)

    @notifications = case params[:tab]
                     when 'likes'
                       scope.where(action: 'liked your post')
                     when 'comments'
                       scope.where(action: 'commented on your post')
                     when 'follow_requests'
                       scope.where(action: 'sent you a follow request')
                     when 'milestones'
                       scope.where("action LIKE ?", 'started reading%')
                     else
                       scope
                     end
  end

  def profile
    @page_title = "Profile"
  end
end
