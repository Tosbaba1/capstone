require "rails_helper"

RSpec.describe "Recommendation onboarding", type: :feature do
  let(:user) { create(:user, name: "Maya", username: "maya") }

  before do
    login_as(user, scope: :user)
  end

  it "lets a user complete onboarding from the home prompt" do
    visit home_path

    expect(page).to have_content("Shape future recommendations in under a minute")

    click_link "Set preferences"

    check "Literary fiction"
    check "Mystery"
    choose "A few times a week"
    choose "Mostly solo"

    click_button "Save preferences"

    expect(page).to have_current_path(home_path)
    expect(page).to have_content("Preferences saved.")
    expect(page).not_to have_content("Shape future recommendations in under a minute")

    user.reload

    expect(user.preferred_genres).to match_array(["Literary fiction", "Mystery"])
    expect(user.reading_frequency).to eq("a_few_times_a_week")
    expect(user.social_reading_preference).to eq("mostly_solo")
    expect(user.recommendation_onboarding_completed_at).to be_present
    expect(user.recommendation_onboarding_skipped_at).to be_nil
  end

  it "lets a user skip onboarding without blocking reading" do
    visit home_path

    click_button "Skip for now"

    expect(page).to have_current_path(home_path)
    expect(page).to have_content("Skipped for now.")
    expect(page).to have_link("Start reading")
    expect(page).not_to have_content("Shape future recommendations in under a minute")

    user.reload

    expect(user.recommendation_onboarding_skipped_at).to be_present
    expect(user.recommendation_onboarding_completed_at).to be_nil
    expect(user.preferred_genres).to eq([])
  end

  it "shows saved preferences when the user returns later" do
    user.update!(
      preferred_genres: ["Fantasy", "Memoir"],
      reading_frequency: "weekly",
      social_reading_preference: "a_mix_of_both",
      recommendation_onboarding_completed_at: Time.current
    )

    visit onboarding_preferences_path

    expect(page).to have_checked_field("Fantasy")
    expect(page).to have_checked_field("Memoir")
    expect(page).to have_checked_field("Weekly")
    expect(page).to have_checked_field("A mix of both")
  end
end
