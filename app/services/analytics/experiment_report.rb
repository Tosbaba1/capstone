module Analytics
  class ExperimentReport
    FLAG_NAMES = %w[session_type session_length presence_visibility].freeze

    def initialize(range:)
      @range = range
    end

    def call
      {
        range: range,
        overview: overview_metrics,
        by_flag: FLAG_NAMES.index_with { |flag_name| metrics_for_flag(flag_name) }
      }
    end

    private

    attr_reader :range

    def overview_metrics
      {
        viewed_home_users: unique_users(events_named(Analytics::EventNames::HOME_VIEWED)),
        started_session_users: unique_users(events_named(Analytics::EventNames::SESSION_STARTED)),
        completed_session_users: unique_users(events_named(Analytics::EventNames::SESSION_COMPLETED)),
        activation_rate: percentage(
          unique_users(events_named(Analytics::EventNames::SESSION_STARTED)),
          unique_users(events_named(Analytics::EventNames::HOME_VIEWED))
        ),
        engagement_rate: percentage(
          unique_users(events_named(Analytics::EventNames::SESSION_COMPLETED)),
          unique_users(events_named(Analytics::EventNames::SESSION_STARTED))
        ),
        retention_24h_rate: percentage(
          unique_users(events_named(Analytics::EventNames::RETURNED_WITHIN_24H)),
          unique_users(events_named(Analytics::EventNames::SESSION_COMPLETED))
        ),
        retention_48h_rate: percentage(
          unique_users(events_named(Analytics::EventNames::RETURNED_WITHIN_48H)),
          unique_users(events_named(Analytics::EventNames::SESSION_COMPLETED))
        ),
        sessions_per_user_per_week: sessions_per_user_per_week(events_named(Analytics::EventNames::SESSION_COMPLETED))
      }
    end

    def metrics_for_flag(flag_name)
      variant_names(flag_name).map do |variant|
        home_events = events_for_variant(Analytics::EventNames::HOME_VIEWED, flag_name, variant)
        started_events = events_for_variant(Analytics::EventNames::SESSION_STARTED, flag_name, variant)
        completed_events = events_for_variant(Analytics::EventNames::SESSION_COMPLETED, flag_name, variant)

        {
          variant: variant,
          viewed_home_users: unique_users(home_events),
          started_session_users: unique_users(started_events),
          completed_session_users: unique_users(completed_events),
          activation_rate: percentage(unique_users(started_events), unique_users(home_events)),
          engagement_rate: percentage(unique_users(completed_events), unique_users(started_events)),
          retention_24h_rate: percentage(
            unique_users(events_for_variant(Analytics::EventNames::RETURNED_WITHIN_24H, flag_name, variant)),
            unique_users(completed_events)
          ),
          retention_48h_rate: percentage(
            unique_users(events_for_variant(Analytics::EventNames::RETURNED_WITHIN_48H, flag_name, variant)),
            unique_users(completed_events)
          ),
          sessions_per_user_per_week: sessions_per_user_per_week(completed_events)
        }
      end
    end

    def variant_names(flag_name)
      FeatureFlags.config.fetch(flag_name).fetch("variants").map(&:to_s)
    end

    def events_for_variant(event_name, flag_name, variant)
      events_named(event_name).select { |event| event.experiment(flag_name).to_s == variant.to_s }
    end

    def events_named(event_name)
      @events_by_name ||= {}
      @events_by_name[event_name] ||= AnalyticsEvent.named(event_name).within(range).to_a
    end

    def unique_users(events)
      events.map(&:user_id).uniq.count
    end

    def percentage(numerator, denominator)
      return 0.0 if denominator.zero?

      ((numerator.to_f / denominator) * 100).round(2)
    end

    def sessions_per_user_per_week(events)
      users = unique_users(events)
      return 0.0 if users.zero?

      weeks = [(range.end - range.begin) / 1.week, 1].max
      (events.count.to_f / users / weeks).round(2)
    end
  end
end
