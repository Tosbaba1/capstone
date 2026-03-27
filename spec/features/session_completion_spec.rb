require "rails_helper"

RSpec.describe "Session completion", type: :feature do
  let(:user) { create(:user, name: "Maya") }

  before do
    login_as(user, scope: :user)
  end

  it "shows the new completion screen when a counted session ends" do
    session = create(
      :session,
      host_user: user,
      duration: 25,
      mode: "silent",
      status: "COMPLETED",
      created_at: 25.minutes.ago
    )

    create(
      :session_participant,
      session: session,
      user: user,
      join_time: session.created_at,
      leave_time: session.ends_at,
      completed: true
    )

    other_reader = create(:user, name: "Nina")
    create(
      :session_participant,
      session: session,
      user: other_reader,
      join_time: session.created_at + 2.minutes,
      leave_time: session.ends_at,
      completed: true
    )

    visit session_path(session)

    expect(page).to have_content("You read for 25 minutes")
    expect(page).to have_content("1 other person read with you")
    expect(page).to have_content("Come back tomorrow")
    expect(page).to have_link("Done", href: home_path)
  end
end
