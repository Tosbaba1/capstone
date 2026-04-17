class ApplicationController < ActionController::Base
  skip_forgery_protection

  before_action :authenticate_user!
  before_action :ensure_onboarding_complete
  before_action :track_last_active
  after_action :track_retention_signals

  helper_method :feature_flags

  private

  def after_sign_in_path_for(resource_or_scope)
    return onboarding_preferences_path if onboarding_redirect_required?(resource_or_scope)

    super
  end

  def after_sign_up_path_for(resource)
    return onboarding_preferences_path if onboarding_redirect_required?(resource)

    super
  end

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

  def ensure_onboarding_complete
    return unless user_signed_in?
    return if devise_controller?
    return unless current_user.recommendation_onboarding_pending?
    return if controller_path == "onboarding_preferences"

    redirect_to onboarding_preferences_path, alert: "Complete your reading preferences to continue."
  end

  def onboarding_redirect_required?(resource_or_scope)
    user = resource_or_scope.is_a?(User) ? resource_or_scope : current_user

    user&.recommendation_onboarding_pending?
  end
end
