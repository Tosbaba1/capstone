FactoryBot.define do
  factory :author do
    name { Faker::Book.author }
    bio { Faker::Lorem.sentence }
    dob { "1970-01-01" }
  end
end
