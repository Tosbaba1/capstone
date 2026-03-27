module Analytics
  Event = Struct.new(:name, :user, :session, :occurred_at, :properties, keyword_init: true)

  module EventNames
    HOME_VIEWED = "home_viewed".freeze
    SESSION_STARTED = "session_started".freeze
    SESSION_JOINED = "session_joined".freeze
    SESSION_COMPLETED = "session_completed".freeze
    SESSION_ABANDONED = "session_abandoned".freeze
    COMPLETION_VIEWED = "completion_viewed".freeze
    PROFILE_VIEWED = "profile_viewed".freeze
    RETURNED_WITHIN_24H = "returned_within_24h".freeze
    RETURNED_WITHIN_48H = "returned_within_48h".freeze
  end

  class << self
    attr_writer :adapter

    def adapter
      @adapter ||= Analytics::Adapters::DatabaseAdapter.new
    end

    def tracker
      @tracker ||= Analytics::Tracker.new(adapter: adapter)
    end

    def track(...)
      tracker.track(...)
    end
  end
end
