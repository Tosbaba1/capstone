class PagesController < ApplicationController
  def library
    @page_title = "Library"
    @user = current_user
    @active_tab = params[:tab] || 'public'
    scope = @user.readings.includes(:book)
    scope = scope.where(is_private: true) if @active_tab == 'private'
    scope = scope.where(is_private: false) if @active_tab == 'public'
    @reading_now  = scope.where(status: 'reading')
    @want_to_read = scope.where(status: 'want_to_read')
    @finished     = scope.where(status: 'finished')
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
