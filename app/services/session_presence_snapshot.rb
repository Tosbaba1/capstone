class SessionPresenceSnapshot
  def initialize(session:, current_user: nil, at: Time.current)
    @session = session
    @current_user = current_user
    @at = at
  end

  def as_json(*)
    {
      id: session.id,
      status: session.status,
      mode: session.mode,
      duration: session.duration,
      ends_at: session.ends_at.iso8601,
      server_now: at.iso8601,
      remaining_seconds: remaining_seconds,
      active_reader_count: active_reader_count,
      readers: active_readers.first(6).map { |reader| reader_payload(reader) }
    }
  end

  private

  attr_reader :at, :current_user, :session

  def active_reader_count
    active_readers.size
  end

  def active_readers
    @active_readers ||= session.active_participants.includes(:user).map(&:user).sort_by do |reader|
      [
        session.host_user_id == reader.id ? 0 : 1,
        current_user&.id == reader.id ? 0 : 1,
        display_name(reader).downcase
      ]
    end
  end

  def remaining_seconds
    [session.ends_at - at, 0].max.to_i
  end

  def reader_payload(reader)
    {
      id: reader.id,
      name: display_name(reader),
      avatar: reader.avatar.presence,
      host: session.host_user_id == reader.id,
      current_user: current_user&.id == reader.id
    }
  end

  def display_name(reader)
    reader.name.presence || reader.username.presence || "Reader"
  end
end
