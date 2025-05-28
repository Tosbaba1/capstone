FactoryBot.define do
  factory :followrequest do
    association :sender, factory: :user
    association :recipient, factory: :user
    status { 'accepted' }
  end
end
