class AnalyticsEvent < ApplicationRecord
  belongs_to :user
  belongs_to :session, optional: true

  validates :name, presence: true
  validates :occurred_at, presence: true

  scope :named, ->(event_name) { where(name: event_name) }
  scope :within, ->(range) { where(occurred_at: range) }

  def experiment(flag_name)
    properties.fetch("experiments", {}).with_indifferent_access[flag_name]
  end
end
