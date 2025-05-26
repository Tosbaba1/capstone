class Reading < ApplicationRecord
  belongs_to :user
  belongs_to :book

  STATUSES = %w[want_to_read reading finished]
  validates :status, inclusion: { in: STATUSES }
end
