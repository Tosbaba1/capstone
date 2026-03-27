FactoryBot.define do
  factory :session_participant do
    association :user
    association :session
    join_time { 5.minutes.ago }
    completed { false }
  end
end
