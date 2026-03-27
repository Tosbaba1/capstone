module Analytics
  class RetentionTracker
    MINIMUM_RETURN_DELAY = 15.minutes
    MAXIMUM_RETURN_WINDOW = 48.hours

    def initialize(user:, occurred_at: Time.current, feature_flags: FeatureFlags.new(user: user))
      @user = user
      @occurred_at = occurred_at
      @feature_flags = feature_flags
    end

    def track!
      qualifying_participants.find_each do |participant|
        elapsed = occurred_at - participant.leave_time

        next if elapsed > MAXIMUM_RETURN_WINDOW

        if elapsed <= 24.hours
          track_once!(Analytics::EventNames::RETURNED_WITHIN_24H, participant, elapsed)
          track_once!(Analytics::EventNames::RETURNED_WITHIN_48H, participant, elapsed)
        else
          track_once!(Analytics::EventNames::RETURNED_WITHIN_48H, participant, elapsed)
        end
      end
    end

    private

    attr_reader :feature_flags, :occurred_at, :user

    def qualifying_participants
      user.completed_session_participants_scope
        .includes(:session)
        .where(leave_time: (occurred_at - MAXIMUM_RETURN_WINDOW)..(occurred_at - MINIMUM_RETURN_DELAY))
    end

    def track_once!(event_name, participant, elapsed)
      return if AnalyticsEvent.exists?(user: user, session: participant.session, name: event_name)

      Analytics.track(
        name: event_name,
        user: user,
        session: participant.session,
        occurred_at: occurred_at,
        properties: session_properties(participant.session).merge(
          hours_since_completion: (elapsed / 1.hour).round(2)
        )
      )
    end

    def session_properties(session)
      {
        experiments: feature_flags.assignments,
        session_duration: session.duration,
        session_mode: session.mode
      }
    end
  end
end
