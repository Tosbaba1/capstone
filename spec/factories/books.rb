FactoryBot.define do
  factory :book do
    title { Faker::Book.title }
    image_url { "http://example.com/book.jpg" }
    association :author
    description { Faker::Lorem.paragraph }
    page_length { rand(100..500) }
    year { rand(1900..2023) }
    genre { Faker::Book.genre }
  end
end
