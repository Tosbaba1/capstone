class AddOnboardingPreferencesToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :preferred_genres, :text, default: "[]", null: false
    add_column :users, :reading_frequency, :string
    add_column :users, :social_reading_preference, :string
    add_column :users, :recommendation_onboarding_completed_at, :datetime
    add_column :users, :recommendation_onboarding_skipped_at, :datetime
  end
end
