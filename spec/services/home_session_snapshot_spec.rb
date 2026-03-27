require "rails_helper"

RSpec.describe HomeSessionSnapshot do
  describe "#active_sessions" do
    it "prioritizes active sessions and readers based on followed participants" do
      current_user = create(:user)
      followed_reader = create(:user, name: "Nina", username: "nina")
      second_reader = create(:user, name: "Theo", username: "theo")
      solo_reader = create(:user, name: "Uma", username: "uma")

      create(:followrequest, sender: current_user, recipient: followed_reader, status: "accepted")

      shared_session = create(:session, host_user: followed_reader, duration: 25, mode: "structured", created_at: 5.minutes.ago)
      solo_session = create(:session, host_user: solo_reader, duration: 20, mode: "silent", created_at: 4.minutes.ago)
      expired_session = create(:session, host_user: create(:user), duration: 20, created_at: 30.minutes.ago)

      create(:session_participant, session: shared_session, user: followed_reader, join_time: 5.minutes.ago, updated_at: 10.seconds.ago)
      create(:session_participant, session: shared_session, user: second_reader, join_time: 4.minutes.ago, updated_at: 8.seconds.ago)
      create(:session_participant, session: solo_session, user: solo_reader, join_time: 4.minutes.ago, updated_at: 9.seconds.ago)
      create(:session_participant, session: expired_session, user: expired_session.host_user, join_time: 30.minutes.ago, updated_at: 30.minutes.ago)

      snapshot = described_class.new(current_user: current_user)

      expect(snapshot.live_presence_count).to eq(3)
      expect(snapshot.presence_readers(limit: 3).first).to eq(followed_reader)

      sessions = snapshot.active_sessions

      expect(sessions.size).to eq(2)
      expect(sessions.first).to eq(shared_session)
      expect(sessions.first.active_reader_count).to eq(2)
      expect(sessions.second).to eq(solo_session)
    end
  end
end
