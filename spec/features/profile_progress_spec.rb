require "rails_helper"

RSpec.describe "Profile progress", type: :feature do
  include ActiveSupport::Testing::TimeHelpers

  let(:user) { create(:user, name: "Maya", username: "maya") }

  around do |example|
    travel_to(Time.zone.local(2026, 3, 26, 12, 0, 0)) { example.run }
  end

  before do
    login_as(user, scope: :user)
  end

  it "shows lightweight progress backed by completed sessions" do
    [
      { started_at: Time.zone.local(2026, 3, 24, 8, 0, 0), duration: 30 },
      { started_at: Time.zone.local(2026, 3, 25, 9, 0, 0), duration: 20 },
      { started_at: Time.zone.local(2026, 3, 26, 7, 30, 0), duration: 25 }
    ].each do |session_data|
      session = create(
        :session,
        host_user: user,
        duration: session_data[:duration],
        status: "COMPLETED",
        created_at: session_data[:started_at]
      )

      create(
        :session_participant,
        session: session,
        user: user,
        join_time: session.created_at,
        leave_time: session.ends_at,
        completed: true
      )
    end

    visit profile_path

    expect(page).to have_content("This week")
    expect(page).to have_content("1 hr 15 min")
    expect(page).to have_content("Sessions completed")
    expect(page).to have_content("3")
    expect(page).to have_content("Current streak")
    expect(page).to have_content("3 days")
    expect(page).to have_content("A simple log of your reading time")
  end
end
