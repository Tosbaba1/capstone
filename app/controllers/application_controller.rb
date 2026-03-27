class ApplicationController < ActionController::Base
  skip_forgery_protection

  before_action :authenticate_user!
  before_action :track_last_active
  after_action :track_retention_signals

  helper_method :feature_flags

  private

  def feature_flags
    @feature_flags ||= FeatureFlags.new(user: current_user)
  end

  def track_analytics_event(name, session_record: nil, properties: {})
    return unless user_signed_in?

    Analytics.track(
      name: name,
      user: current_user,
      session: session_record,
      properties: analytics_properties(properties)
    )
  end

  def track_last_active
    return unless user_signed_in?
    return if current_user.last_active.present? && current_user.last_active > 1.minute.ago

    current_user.update_column(:last_active, Time.current)
  end

  def analytics_properties(extra_properties = {})
    {
      experiments: feature_flags.assignments
    }.merge(extra_properties)
  end

  def track_retention_signals
    return unless user_signed_in?
    return unless request.get?
    return unless request.format.html?

    Analytics::RetentionTracker.new(
      user: current_user,
      occurred_at: Time.current,
      feature_flags: feature_flags
    ).track!
  end
end
