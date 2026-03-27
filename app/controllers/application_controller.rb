class ApplicationController < ActionController::Base
  skip_forgery_protection

  before_action :authenticate_user!
  before_action :track_last_active

  private

  def track_last_active
    return unless user_signed_in?
    return if current_user.last_active.present? && current_user.last_active > 1.minute.ago

    current_user.update_column(:last_active, Time.current)
  end
end
