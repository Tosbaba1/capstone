require "rails_helper"

RSpec.describe SessionPresenceSnapshot do
  describe "#as_json" do
    it "returns server-derived timer data and sorted active readers" do
      now = Time.zone.parse("2026-03-26 09:30:00")
      host = create(:user, name: "Host Reader")
      current_user = create(:user, name: "Current Reader")
      guest = create(:user, name: "Guest Reader")
      session = create(:session, host_user: host, duration: 25, created_at: now - 5.minutes)

      create(:session_participant, session: session, user: guest, join_time: now - 4.minutes, updated_at: now - 4.seconds)
      create(:session_participant, session: session, user: current_user, join_time: now - 3.minutes, updated_at: now - 3.seconds)
      create(:session_participant, session: session, user: host, join_time: now - 5.minutes, updated_at: now - 2.seconds)

      allow(Time).to receive(:current).and_return(now)

      snapshot = described_class.new(session: session, current_user: current_user, at: now).as_json

      expect(snapshot[:server_now]).to eq(now.iso8601)
      expect(snapshot[:ends_at]).to eq(session.ends_at.iso8601)
      expect(snapshot[:remaining_seconds]).to eq(20.minutes.to_i)
      expect(snapshot[:active_reader_count]).to eq(3)
      expect(snapshot[:readers].map { |reader| reader[:name] }).to eq(["Host Reader", "Current Reader", "Guest Reader"])
    end

    it "omits reader identities when presence visibility is count only" do
      now = Time.zone.parse("2026-03-26 09:30:00")
      host = create(:user, name: "Host Reader")
      guest = create(:user, name: "Guest Reader")
      session = create(:session, host_user: host, duration: 25, created_at: now - 5.minutes)

      create(:session_participant, session: session, user: guest, join_time: now - 4.minutes, updated_at: now - 4.seconds)
      create(:session_participant, session: session, user: host, join_time: now - 5.minutes, updated_at: now - 2.seconds)

      snapshot = described_class.new(
        session: session,
        current_user: host,
        at: now,
        presence_visibility: "count_only"
      ).as_json

      expect(snapshot[:presence_visibility]).to eq("count_only")
      expect(snapshot[:active_reader_count]).to eq(2)
      expect(snapshot[:readers]).to eq([])
    end
  end
end
