require "rails_helper"

RSpec.describe "Session room", type: :feature do
  let(:user) { create(:user, :onboarding_complete, name: "Maya") }

  before do
    login_as(user, scope: :user)
  end

  it "shows an immersive reading room with real reading and presence data" do
    author = create(:author, name: "Toni Morrison")
    book = create(:book, title: "Beloved", author: author)
    create(:reading, user: user, book: book, status: "reading", progress: 42, updated_at: 1.minute.ago)

    session = create(:session, host_user: user, duration: 25, mode: "silent", created_at: 2.minutes.ago)
    create(:session_participant, session: session, user: user, join_time: 2.minutes.ago, updated_at: 5.seconds.ago)

    other_reader = create(:user, name: "Nina")
    create(:session_participant, session: session, user: other_reader, join_time: 1.minute.ago, updated_at: 5.seconds.ago)

    visit session_path(session)

    expect(page).to have_content("Beloved")
    expect(page).to have_content("by Toni Morrison")
    expect(page).to have_content("42% through")
    expect(page).to have_content("2 readers")
    expect(page).to have_content("Reading room")
    expect(page).to have_content("View readers")
    expect(page).to have_content("Presence stays at the edges")
    expect(page).to have_button("Leave session")
    expect(page).not_to have_css(".app-header")
  end
end
