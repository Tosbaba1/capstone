class HomeSessionSnapshot
  PRESENCE_WINDOW = 2.hours
  ACTIVE_SESSION_WINDOW = 90.minutes
  DEFAULT_SESSION_LIMIT = 4

  Session = Struct.new(:book, :readings, :started_at, :mode, keyword_init: true) do
    def reader_count
      readings.map(&:user_id).uniq.count
    end

    def latest_activity_at
      readings.map(&:updated_at).compact.max
    end

    def readers
      readings.map(&:user).uniq(&:id)
    end
  end

  def initialize(current_user:)
    @current_user = current_user
  end

  def live_presence_count
    live_presence_scope.distinct.count(:user_id)
  end

  def presence_readers(limit: 6)
    prioritized_readings.first(limit)
  end

  def active_sessions(limit: DEFAULT_SESSION_LIMIT)
    grouped_sessions.first(limit)
  end

  private

  attr_reader :current_user

  def followed_user_ids
    @followed_user_ids ||= current_user.following.ids
  end

  def live_presence_scope
    @live_presence_scope ||= Reading
      .includes(:user, book: :author)
      .joins(:user)
      .where(status: "reading", is_private: false, updated_at: PRESENCE_WINDOW.ago..Time.current)
      .where.not(user_id: current_user.id)
      .merge(User.publicly_visible)
      .order(updated_at: :desc)
  end

  def session_scope
    @session_scope ||= live_presence_scope.where(updated_at: ACTIVE_SESSION_WINDOW.ago..Time.current).to_a
  end

  def prioritized_readings
    @prioritized_readings ||= live_presence_scope.to_a.sort_by do |reading|
      [
        followed_user_ids.include?(reading.user_id) ? 0 : 1,
        -reading.updated_at.to_i
      ]
    end
  end

  def grouped_sessions
    @grouped_sessions ||= session_scope
      .group_by(&:book_id)
      .values
      .map { |readings| build_session(readings) }
      .sort_by do |session|
        [
          -followed_reader_count(session),
          -session.reader_count,
          -session.latest_activity_at.to_i
        ]
      end
  end

  def build_session(readings)
    sorted_readings = readings.sort_by(&:updated_at)

    Session.new(
      book: sorted_readings.first.book,
      readings: sorted_readings.reverse,
      started_at: sorted_readings.first.updated_at,
      mode: session_mode_for(sorted_readings)
    )
  end

  def followed_reader_count(session)
    session.readings.count { |reading| followed_user_ids.include?(reading.user_id) }
  end

  def session_mode_for(readings)
    case readings.map(&:user_id).uniq.count
    when 4..Float::INFINITY
      "Reading Circle"
    when 2..3
      "Quiet Co-Reading"
    else
      "Open Table"
    end
  end
end
