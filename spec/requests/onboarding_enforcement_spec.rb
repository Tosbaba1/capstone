require "rails_helper"

RSpec.describe "Onboarding enforcement", type: :request do
  it "routes new registrations directly into onboarding" do
    post user_registration_path, params: {
      user: {
        email: "new-reader@example.com",
        password: "password",
        password_confirmation: "password",
        name: "New Reader",
        username: "newreader"
      }
    }

    expect(response).to redirect_to(onboarding_preferences_path)
    expect(User.find_by(email: "new-reader@example.com")).to be_present
  end

  it "redirects incomplete users away from main app pages" do
    user = create(:user)
    sign_in user

    get home_path

    expect(response).to redirect_to(onboarding_preferences_path)

    get library_path

    expect(response).to redirect_to(onboarding_preferences_path)
  end

  it "unlocks the app once onboarding is completed" do
    user = create(:user)
    sign_in user

    patch onboarding_preferences_path, params: {
      user: {
        preferred_genres: ["Mystery"],
        reading_frequency: "weekly",
        social_reading_preference: "mostly_solo"
      }
    }

    expect(response).to redirect_to(home_path)

    user.reload

    expect(user.recommendation_onboarding_completed_at).to be_present
    expect(user.preferred_genres).to eq(["Mystery"])

    get home_path

    expect(response).to have_http_status(:ok)
  end

  it "does not redirect users who already completed onboarding" do
    sign_in create(:user, :onboarding_complete)

    get home_path

    expect(response).to have_http_status(:ok)
  end

  it "redirects previously skipped users into onboarding until they complete it" do
    user = create(:user, recommendation_onboarding_skipped_at: Time.current)
    sign_in user

    get home_path

    expect(response).to redirect_to(onboarding_preferences_path)
  end
end
