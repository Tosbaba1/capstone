# == Schema Information
#
# Table name: followrequests
#
#  id           :bigint           not null, primary key
#  status       :string           default("pending")
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  recipient_id :integer
#  sender_id    :integer
#
FactoryBot.define do
  factory :followrequest do
    association :sender, factory: :user
    association :recipient, factory: :user
    status { 'accepted' }
  end
end
