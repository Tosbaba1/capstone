require "rails_helper"

RSpec.describe HomeSessionSnapshot do
  describe "#active_sessions" do
    it "groups recent public reading activity into joinable sessions and prioritizes followed readers" do
      current_user = create(:user)
      followed_reader = create(:user, name: "Nina", username: "nina")
      second_reader = create(:user, name: "Theo", username: "theo")
      solo_reader = create(:user, name: "Uma", username: "uma")
      private_reader = create(:user, is_private: true, name: "Iris", username: "iris")

      create(:followrequest, sender: current_user, recipient: followed_reader, status: "accepted")

      shared_book = create(:book, title: "The Waves")
      solo_book = create(:book, title: "Passing")
      private_book = create(:book, title: "Beloved")

      create(:reading, user: followed_reader, book: shared_book, status: "reading", is_private: false, updated_at: 20.minutes.ago)
      create(:reading, user: second_reader, book: shared_book, status: "reading", is_private: false, updated_at: 35.minutes.ago)
      create(:reading, user: solo_reader, book: solo_book, status: "reading", is_private: false, updated_at: 10.minutes.ago)
      create(:reading, user: private_reader, book: private_book, status: "reading", is_private: false, updated_at: 15.minutes.ago)
      create(:reading, user: current_user, book: create(:book), status: "reading", is_private: false, updated_at: 5.minutes.ago)

      snapshot = described_class.new(current_user: current_user)

      expect(snapshot.live_presence_count).to eq(3)
      expect(snapshot.presence_readers(limit: 3).first.user).to eq(followed_reader)

      sessions = snapshot.active_sessions

      expect(sessions.size).to eq(2)
      expect(sessions.first.book).to eq(shared_book)
      expect(sessions.first.reader_count).to eq(2)
      expect(sessions.first.mode).to eq("Quiet Co-Reading")
      expect(sessions.first.started_at.to_i).to eq(35.minutes.ago.to_i)
      expect(sessions.second.book).to eq(solo_book)
      expect(sessions.second.mode).to eq("Open Table")
    end
  end
end
