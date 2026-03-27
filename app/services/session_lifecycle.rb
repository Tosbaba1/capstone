class SessionLifecycle
  class SessionUnavailableError < StandardError; end
  class NotParticipantError < StandardError; end

  def self.finalize_expired_sessions!(scope: Session.active)
    scope.find_each do |session|
      finalize_expired_session!(session)
    end
  end

  def self.finalize_expired_session!(session, at: Time.current)
    return session unless session.active? && session.timer_ended?(at: at)

    session.with_lock do
      next session unless session.active?

      session.session_participants.current.includes(:user).find_each do |participant|
        new(user: participant.user, session: session, at: session.ends_at).send(
          :finalize_participant!,
          participant,
          completed: true,
          leave_time: session.ends_at,
          credited_seconds: session.duration.minutes.to_i
        )
      end

      session.update!(status: "COMPLETED")
    end

    session
  end

  def initialize(user:, session: nil, at: Time.current)
    @user = user
    @session = session
    @at = at
  end

  def start!(duration:, mode:)
    close_other_active_participations!

    created_session = Session.create!(
      host_user: user,
      duration: duration,
      mode: mode,
      status: "ACTIVE"
    )

    created_session.session_participants.create!(
      user: user,
      join_time: at
    )

    touch_user!
    created_session
  end

  def join!
    ensure_joinable_session!
    close_other_active_participations!

    participant = session.session_participants.find_or_initialize_by(user: user)

    if participant.persisted?
      raise SessionUnavailableError, "You already left this session." if participant.leave_time.present?

      participant.touch
    else
      participant.join_time = at
      participant.save!
    end

    touch_user!
    participant
  end

  def heartbeat!
    ensure_joinable_session!
    participant = session.session_participants.find_by(user: user, leave_time: nil)
    raise NotParticipantError, "Join the session before updating presence." if participant.blank?

    participant.touch
    touch_user!
    participant
  end

  def leave!
    finalize_leave!(force_complete: false)
  end

  def complete!
    finalize_leave!(force_complete: true)
  end

  private

  attr_reader :at, :session, :user

  def ensure_joinable_session!
    raise SessionUnavailableError, "Session not found." if session.blank?

    self.class.finalize_expired_session!(session, at: at)
    raise SessionUnavailableError, "This session is no longer active." unless session.active?
  end

  def close_other_active_participations!
    active_scope = user.session_participants
      .joins(:session)
      .merge(Session.active)
      .where(leave_time: nil)
    active_scope = active_scope.where.not(session_id: session.id) if session.present?

    active_scope.includes(:session).find_each do |participant|
      self.class.new(user: user, session: participant.session, at: at).leave!
    end
  end

  def finalize_leave!(force_complete:)
    participant = session.session_participants.find_by(user: user)
    raise NotParticipantError, "You are not part of this session." if participant.blank?
    return participant if participant.leave_time.present?

    completed = force_complete || session.timer_ended?(at: at) || participant.completion_ratio(at: at) > 0.5
    leave_time = (force_complete || session.timer_ended?(at: at)) ? session.ends_at : at
    credited_seconds = if completed
      (force_complete || session.timer_ended?(at: at)) ? session.duration.minutes.to_i : participant.elapsed_seconds(at: at)
    else
      0
    end

    finalize_participant!(
      participant,
      completed: completed,
      leave_time: leave_time,
      credited_seconds: credited_seconds
    )
    refresh_session_status!
    participant
  end

  def finalize_participant!(participant, completed:, leave_time:, credited_seconds:)
    already_completed = participant.completed?

    participant.update!(
      leave_time: leave_time,
      completed: completed
    )

    if completed && !already_completed
      user.with_lock do
        user.update_columns(
          total_reading_time: user.total_reading_time + credited_seconds,
          sessions_completed: user.sessions_completed + 1,
          last_active: leave_time
        )
      end
    else
      user.update_column(:last_active, leave_time)
    end
  end

  def refresh_session_status!
    return unless session.active?
    return if session.session_participants.current.exists?

    new_status = if session.timer_ended?(at: at) || session.session_participants.where(completed: true).exists?
      "COMPLETED"
    else
      "ABANDONED"
    end

    session.update!(status: new_status)
  end

  def touch_user!
    user.update_column(:last_active, at)
  end
end
