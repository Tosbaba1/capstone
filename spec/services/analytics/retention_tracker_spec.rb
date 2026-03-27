require "rails_helper"

RSpec.describe Analytics::RetentionTracker do
  describe "#track!" do
    it "emits 24h and 48h return events once for qualifying completed sessions" do
      now = Time.zone.parse("2026-03-27 12:00:00")
      user = create(:user)
      session = create(:session, host_user: user, status: "COMPLETED", created_at: now - 23.hours)
      create(
        :session_participant,
        session: session,
        user: user,
        join_time: session.created_at,
        leave_time: now - 23.hours,
        completed: true
      )

      tracker = described_class.new(user: user, occurred_at: now)

      expect { tracker.track! }
        .to change { AnalyticsEvent.named(Analytics::EventNames::RETURNED_WITHIN_24H).count }.by(1)
        .and change { AnalyticsEvent.named(Analytics::EventNames::RETURNED_WITHIN_48H).count }.by(1)

      expect { tracker.track! }
        .not_to change { AnalyticsEvent.named(Analytics::EventNames::RETURNED_WITHIN_24H).count }
    end
  end
end
