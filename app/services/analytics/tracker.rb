module Analytics
  class Tracker
    def initialize(adapter:)
      @adapter = adapter
    end

    def track(name:, user:, session: nil, properties: {}, occurred_at: Time.current)
      return if user.blank?

      event = Event.new(
        name: name.to_s,
        user: user,
        session: session,
        occurred_at: occurred_at,
        properties: sanitize(properties)
      )

      adapter.track(event)
    rescue StandardError => error
      Rails.logger.warn("[analytics] failed name=#{name} user_id=#{user&.id} error=#{error.class}: #{error.message}")
      nil
    end

    private

    attr_reader :adapter

    def sanitize(value)
      case value
      when Hash
        value.each_with_object({}) do |(key, nested_value), sanitized|
          sanitized[key.to_s] = sanitize(nested_value)
        end
      when Array
        value.map { |nested_value| sanitize(nested_value) }
      when Time, Date, DateTime, ActiveSupport::TimeWithZone
        value.iso8601
      when BigDecimal
        value.to_f
      when NilClass, Numeric, String, TrueClass, FalseClass
        value
      else
        value.to_s
      end
    end
  end
end
