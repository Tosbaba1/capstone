# == Schema Information
#
# Table name: books
#
#  id          :bigint           not null, primary key
#  description :text
#  genre       :string
#  image_url   :string
#  page_length :integer
#  title       :string
#  year        :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  author_id   :integer
#  library_id  :integer
#
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
