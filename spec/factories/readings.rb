# == Schema Information
#
# Table name: readings
#
#  id         :bigint           not null, primary key
#  progress   :integer
#  rating     :integer
#  review     :text
#  status     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  book_id    :integer
#  user_id    :integer
#
# Indexes
#
#  index_readings_on_user_id_and_book_id  (user_id,book_id) UNIQUE
#
FactoryBot.define do
  factory :reading do
    association :user
    association :book
    status { "want_to_read" }
  end
end
