# == Schema Information
#
# Table name: readings
#
#  id         :bigint           not null, primary key
#  is_private :boolean          default(FALSE)
#  progress   :integer
#  rating     :decimal(2, 1)
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
class Reading < ApplicationRecord
  belongs_to :user
  belongs_to :book

  STATUSES = %w[want_to_read reading finished]
  STATUS_OPTIONS = [
    ['Currently reading', 'reading'],
    ['Want to read', 'want_to_read'],
    ['Finished reading', 'finished']
  ].freeze
  validates :status, inclusion: { in: STATUSES }
  validates :progress, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100
  }, allow_nil: true
  validates :rating, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 5
  }, allow_nil: true
  validates :book_id, uniqueness: { scope: :user_id }
end
