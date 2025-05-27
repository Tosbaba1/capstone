# == Schema Information
#
# Table name: readings
#
#  id         :bigint           not null, primary key
#  rating     :integer
#  status     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  book_id    :integer
#  user_id    :integer
#
class Reading < ApplicationRecord
  belongs_to :user
  belongs_to :book

  STATUSES = %w[want_to_read reading finished]
  validates :status, inclusion: { in: STATUSES }
  validates :book_id, uniqueness: { scope: :user_id }
  validates :progress, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
end
