# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  avatar                 :string
#  banner                 :string
#  bio                    :text
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  is_private             :boolean          default(FALSE)
#  name                   :string
#  posts_count            :integer
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  username               :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password" }
    sequence(:name) { |n| "Reader #{n}" }
    sequence(:username) { |n| "reader#{n}" }
    preferred_genres { [] }

    trait :onboarding_complete do
      preferred_genres { ["Fantasy"] }
      reading_frequency { "weekly" }
      social_reading_preference { "a_mix_of_both" }
      recommendation_onboarding_completed_at { Time.current }
      recommendation_onboarding_skipped_at { nil }
    end
  end
end
