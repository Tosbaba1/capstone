module Analytics
  module Adapters
    class DatabaseAdapter
      def track(event)
        analytics_event = AnalyticsEvent.create!(
          name: event.name,
          user: event.user,
          session: event.session,
          occurred_at: event.occurred_at,
          properties: event.properties
        )

        log_event(analytics_event) if Rails.env.development? || Rails.env.test?
        analytics_event
      end

      private

      def log_event(event)
        Rails.logger.info(
          "[analytics] #{event.name} user_id=#{event.user_id} session_id=#{event.session_id || 'none'} properties=#{event.properties.to_json}"
        )
      end
    end
  end
end
