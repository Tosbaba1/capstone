class OnboardingPreferencesController < ApplicationController
  def show
    @page_title = "Reading preferences"
    @user = current_user
    @onboarding_locked = current_user.recommendation_onboarding_pending?
    load_onboarding_options
  end

  def update
    @user = current_user
    @onboarding_locked = current_user.recommendation_onboarding_pending?
    @user.assign_attributes(onboarding_preferences_params)
    @user.recommendation_onboarding_completed_at = Time.current
    @user.recommendation_onboarding_skipped_at = nil

    if @user.save(context: :onboarding)
      redirect_to home_path, notice: "Preferences saved. Welcome to Nouvelle."
    else
      @page_title = "Reading preferences"
      load_onboarding_options
      render :show, status: :unprocessable_entity
    end
  end

  private

  def onboarding_preferences_params
    params.require(:user).permit(:reading_frequency, :social_reading_preference, preferred_genres: [])
  end

  def load_onboarding_options
    @genre_options = User::ONBOARDING_GENRE_OPTIONS
    @reading_frequency_options = [
      { value: "daily", label: "Daily", description: "Reading is part of most days." },
      { value: "a_few_times_a_week", label: "A few times a week", description: "A steady habit, with room to breathe." },
      { value: "weekly", label: "Weekly", description: "A calmer once-or-twice-a-week pace." },
      { value: "whenever_i_can", label: "Whenever I can", description: "It comes in waves, and that still counts." }
    ]
    @social_reading_preference_options = [
      { value: "mostly_solo", label: "Mostly solo", description: "Quiet recommendations first, with company as an option." },
      { value: "a_mix_of_both", label: "A mix of both", description: "A balanced mix of private and shared reading moments." },
      { value: "mostly_social", label: "Mostly social", description: "Rooms, clubs, and social momentum feel energizing." }
    ]
  end
end
