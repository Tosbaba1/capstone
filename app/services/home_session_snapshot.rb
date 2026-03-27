class HomeSessionSnapshot
  DEFAULT_SESSION_LIMIT = 4

  def initialize(current_user:)
    @current_user = current_user
  end

  def live_presence_count
    prioritized_presence_participants.map(&:user_id).uniq.count
  end

  def presence_readers(limit: 6)
    prioritized_presence_participants.first(limit).map(&:user)
  end

  def active_sessions(limit: DEFAULT_SESSION_LIMIT)
    prioritized_sessions.first(limit)
  end

  private

  attr_reader :current_user

  def followed_user_ids
    @followed_user_ids ||= current_user.following.ids
  end

  def joinable_sessions
    @joinable_sessions ||= Session.active
      .includes(:host_user, session_participants: :user)
      .to_a
      .reject { |session| session.timer_ended? }
  end

  def prioritized_presence_participants
    @prioritized_presence_participants ||= joinable_sessions
      .flat_map(&:active_participants)
      .uniq { |participant| participant.user_id }
      .reject { |participant| participant.user_id == current_user.id }
      .sort_by do |participant|
        [
          followed_user_ids.include?(participant.user_id) ? 0 : 1,
          -participant.updated_at.to_i
        ]
      end
  end

  def prioritized_sessions
    @prioritized_sessions ||= joinable_sessions
      .reject { |session| session.host_user_id == current_user.id && session.active_reader_count.zero? }
      .sort_by do |session|
        [
          -followed_reader_count(session),
          -session.active_reader_count,
          session.ends_at.to_i
        ]
      end
  end

  def followed_reader_count(session)
    session.active_participants.count { |participant| followed_user_ids.include?(participant.user_id) }
  end
end
