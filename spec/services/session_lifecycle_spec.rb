require "rails_helper"

RSpec.describe SessionLifecycle do
  describe "#start!" do
    it "creates an active session and adds the host as a participant" do
      user = create(:user)
      now = Time.current.change(usec: 0)

      session = described_class.new(user: user, at: now).start!(duration: 25, mode: "silent")

      expect(session).to be_persisted
      expect(session.status).to eq("ACTIVE")
      expect(session.host_user).to eq(user)
      expect(session.session_participants.count).to eq(1)
      expect(session.session_participants.first.user).to eq(user)
      expect(session.session_participants.first.join_time.to_i).to eq(now.to_i)
      expect(AnalyticsEvent.named(Analytics::EventNames::SESSION_STARTED).count).to eq(1)
    end
  end

  describe "#join!" do
    it "adds a second participant to an active session" do
      host = create(:user)
      joiner = create(:user)
      session = create(:session, host_user: host)

      create(:session_participant, session: session, user: host, join_time: 3.minutes.ago)

      participant = described_class.new(user: joiner, session: session).join!

      expect(participant).to be_persisted
      expect(participant.user).to eq(joiner)
      expect(session.session_participants.count).to eq(2)
      expect(AnalyticsEvent.named(Analytics::EventNames::SESSION_JOINED).count).to eq(1)
    end
  end

  describe "#leave!" do
    it "marks the participant completed after more than half the session and updates totals" do
      user = create(:user)
      session = create(:session, host_user: user, duration: 20)
      participant = create(:session_participant, session: session, user: user, join_time: 12.minutes.ago)

      described_class.new(user: user, session: session, at: Time.current).leave!

      participant.reload
      user.reload
      session.reload

      expect(participant.completed).to eq(true)
      expect(user.sessions_completed).to eq(1)
      expect(user.total_reading_time).to be >= 12.minutes.to_i
      expect(session.status).to eq("COMPLETED")
      expect(AnalyticsEvent.named(Analytics::EventNames::SESSION_COMPLETED).count).to eq(1)
    end

    it "marks the session abandoned when the only participant leaves too early" do
      user = create(:user)
      session = create(:session, host_user: user, duration: 25)
      participant = create(:session_participant, session: session, user: user, join_time: 8.minutes.ago)

      described_class.new(user: user, session: session, at: Time.current).leave!

      participant.reload
      user.reload
      session.reload

      expect(participant.completed).to eq(false)
      expect(user.sessions_completed).to eq(0)
      expect(user.total_reading_time).to eq(0)
      expect(session.status).to eq("ABANDONED")
      expect(AnalyticsEvent.named(Analytics::EventNames::SESSION_ABANDONED).count).to eq(1)
    end
  end
end
