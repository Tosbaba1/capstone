FactoryBot.define do
  factory :reading do
    association :user
    association :book
    status { "want_to_read" }
  end
end
