FactoryBot.define do
  factory :session do
    association :host_user, factory: :user
    duration { 25 }
    mode { "silent" }
    status { "ACTIVE" }
  end
end
