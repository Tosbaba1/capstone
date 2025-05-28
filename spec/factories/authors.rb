# == Schema Information
#
# Table name: authors
#
#  id          :bigint           not null, primary key
#  bio         :string
#  books_count :integer
#  dob         :string
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
FactoryBot.define do
  factory :author do
    name { Faker::Book.author }
    bio { Faker::Quote.famous_last_words }
    dob { "1970-01-01" }
  end
end
