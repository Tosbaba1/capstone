class SessionParticipant < ApplicationRecord
  PRESENCE_WINDOW = 15.seconds

  belongs_to :user
  belongs_to :session

  scope :completed, -> { where(completed: true) }
  scope :current, -> { where(leave_time: nil) }
  scope :active_now, ->(window: PRESENCE_WINDOW) { current.where(updated_at: window.ago..Time.current) }

  validates :join_time, presence: true
  validates :user_id, uniqueness: { scope: :session_id }
  validate :leave_time_after_join_time

  def active?
    leave_time.nil?
  end

  def elapsed_seconds(at: Time.current)
    finish_time = [at, leave_time || at, session.ends_at].compact.min
    [[finish_time - join_time, 0].max, session.duration.minutes].min.to_i
  end

  def completion_ratio(at: Time.current)
    return 0 if session.duration.to_i.zero?

    elapsed_seconds(at: at).to_f / session.duration.minutes
  end

  def credited_seconds
    return 0 unless completed?

    elapsed_seconds(at: leave_time || Time.current)
  end

  def credited_minutes
    (credited_seconds / 60.0).round
  end

  private

  def leave_time_after_join_time
    return if leave_time.blank? || join_time.blank? || leave_time >= join_time

    errors.add(:leave_time, "must be after join time")
  end
end
