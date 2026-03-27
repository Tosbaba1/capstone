class SessionsController < ApplicationController
  before_action :set_session, only: [:show, :join, :leave, :heartbeat, :complete, :presence]

  rescue_from SessionLifecycle::SessionUnavailableError, with: :handle_session_unavailable
  rescue_from SessionLifecycle::NotParticipantError, with: :handle_not_participant

  def new
    SessionLifecycle.finalize_expired_sessions!
    @page_title = "Start Session"
    @session = Session.new(duration: feature_flags.session_length, mode: feature_flags.session_type)
    @active_sessions = HomeSessionSnapshot.new(current_user: current_user).active_sessions
  end

  def create
    started_session = SessionLifecycle.new(user: current_user).start!(**session_params.to_h.symbolize_keys)
    redirect_to session_path(started_session), notice: "Your reading session is live."
  rescue ActiveRecord::RecordInvalid
    @page_title = "Start Session"
    @session = Session.new(session_params)
    @active_sessions = HomeSessionSnapshot.new(current_user: current_user).active_sessions
    render :new, status: :unprocessable_entity
  end

  def show
    SessionLifecycle.finalize_expired_session!(@session)
    @page_title = "Reading Session"
    @participant = @session.session_participants.includes(:user).find_by(user: current_user)
    @current_reading = current_user.readings
      .includes(book: :author)
      .where(status: "reading")
      .order(updated_at: :desc)
      .first
    @presence_snapshot = SessionPresenceSnapshot.new(
      session: @session,
      current_user: current_user,
      presence_visibility: feature_flags.presence_visibility
    ).as_json
    @immersive_session_room = @participant.present? && @participant.leave_time.blank? && @session.active?

    if @participant.present?
      track_completion_view if @participant.leave_time.present?
      return
    end

    redirect_to home_path, alert: "Join the session from Home or the session list first."
  end

  def join
    SessionLifecycle.new(user: current_user, session: @session).join!
    redirect_to session_path(@session), notice: "You joined the reading session."
  end

  def leave
    participant = SessionLifecycle.new(user: current_user, session: @session).leave!
    notice = participant.completed? ? "Session completed and saved to your totals." : "You left the session early."
    redirect_to session_path(@session), notice: notice
  end

  def heartbeat
    SessionLifecycle.new(user: current_user, session: @session).heartbeat!
    render json: SessionPresenceSnapshot.new(
      session: @session,
      current_user: current_user,
      presence_visibility: feature_flags.presence_visibility
    ).as_json
  end

  def complete
    SessionLifecycle.new(user: current_user, session: @session, at: [Time.current, @session.ends_at].max).complete!
    render json: { redirect_url: session_path(@session) }
  end

  def presence
    SessionLifecycle.finalize_expired_session!(@session)
    render json: SessionPresenceSnapshot.new(
      session: @session,
      current_user: current_user,
      presence_visibility: feature_flags.presence_visibility
    ).as_json
  end

  private

  def session_params
    params.require(:session).permit(:duration, :mode)
  end

  def set_session
    @session = Session.includes(:host_user, session_participants: :user).find(params[:id])
  end

  def handle_session_unavailable(exception)
    redirect_to home_path, alert: exception.message
  end

  def handle_not_participant(exception)
    redirect_to home_path, alert: exception.message
  end

  def track_completion_view
    track_analytics_event(
      Analytics::EventNames::COMPLETION_VIEWED,
      session_record: @session,
      properties: {
        completed: @participant.completed?,
        credited_minutes: @participant.credited_minutes,
        session_duration: @session.duration,
        session_mode: @session.mode
      }
    )
  end
end
