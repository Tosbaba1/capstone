class NotificationsController < ApplicationController
  def mark_read
    notification = current_user.notifications.find(params[:id])
    notification.update(read: true)
    redirect_to '/notifications'
  end

  def mark_unread
    notification = current_user.notifications.find(params[:id])
    notification.update(read: false)
    redirect_to '/notifications'
  end
end
