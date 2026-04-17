require "rails_helper"

RSpec.describe "Recommendation onboarding", type: :feature do
  let(:user) { create(:user, name: "Maya", username: "maya") }

  before do
    login_as(user, scope: :user)
  end

  it "redirects incomplete users into onboarding before home" do
    visit home_path

    expect(page).to have_current_path(onboarding_preferences_path)
    expect(page).to have_content("Tell us enough to personalize Nouvelle before you jump in.")
  end

  it "lets a user complete onboarding and unlock the app" do
    visit home_path

    check "Literary fiction"
    check "Mystery"
    choose "A few times a week"
    choose "Mostly solo"

    click_button "Save and continue"

    expect(page).to have_current_path(home_path)
    expect(page).to have_content("Preferences saved. Welcome to Nouvelle.")

    user.reload

    expect(user.preferred_genres).to match_array(["Literary fiction", "Mystery"])
    expect(user.reading_frequency).to eq("a_few_times_a_week")
    expect(user.social_reading_preference).to eq("mostly_solo")
    expect(user.recommendation_onboarding_completed_at).to be_present
    expect(user.recommendation_onboarding_skipped_at).to be_nil
  end

  it "keeps incomplete users blocked until all onboarding fields are completed" do
    visit onboarding_preferences_path

    click_button "Save and continue"

    expect(page).to have_current_path(onboarding_preferences_path)
    expect(page).to have_content("Please complete all three preference questions.")
    expect(page).to have_content("Preferred genres must include at least one genre")
    expect(page).to have_content("Reading frequency must be selected")
    expect(page).to have_content("Social reading preference must be selected")
  end

  it "shows saved preferences when the user returns later" do
    user.update!(
      preferred_genres: ["Fantasy", "Memoir"],
      reading_frequency: "weekly",
      social_reading_preference: "a_mix_of_both",
      recommendation_onboarding_completed_at: Time.current,
      recommendation_onboarding_skipped_at: nil
    )

    visit onboarding_preferences_path

    expect(page).to have_checked_field("Fantasy")
    expect(page).to have_checked_field("Memoir")
    expect(page).to have_checked_field("Weekly")
    expect(page).to have_checked_field("A mix of both")
    expect(page).to have_link("Back to home", href: home_path)
  end
end
