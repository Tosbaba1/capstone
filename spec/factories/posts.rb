# == Schema Information
#
# Table name: posts
#
#  id             :bigint           not null, primary key
#  comments_count :integer
#  content        :text
#  likes_count    :integer
#  poll_data      :jsonb
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  book_id        :integer
#  creator_id     :integer
#
FactoryBot.define do
  factory :post do
    association :creator, factory: :user
    content { Faker::Quote.famous_last_words }
  end
end
