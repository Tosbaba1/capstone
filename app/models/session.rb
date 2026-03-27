class Session < ApplicationRecord
  DURATIONS = [20, 25, 30].freeze
  MODES = %w[silent structured].freeze
  STATUSES = %w[NOT_STARTED ACTIVE COMPLETED ABANDONED].freeze

  belongs_to :host_user, class_name: "User", inverse_of: :hosted_sessions
  has_many :session_participants, dependent: :destroy
  has_many :users, through: :session_participants

  scope :active, -> { where(status: "ACTIVE") }

  validates :duration, inclusion: { in: DURATIONS }
  validates :mode, inclusion: { in: MODES }
  validates :status, inclusion: { in: STATUSES }

  def ends_at
    created_at + duration.minutes
  end

  def timer_ended?(at: Time.current)
    created_at.present? && at >= ends_at
  end

  def active_participants(window: SessionParticipant::PRESENCE_WINDOW)
    session_participants.active_now(window: window)
  end

  def active_readers(window: SessionParticipant::PRESENCE_WINDOW)
    active_participants(window: window).map(&:user)
  end

  def active_reader_count(window: SessionParticipant::PRESENCE_WINDOW)
    active_participants(window: window).distinct.count(:user_id)
  end

  def other_reader_count_for(user)
    if association(:session_participants).loaded?
      session_participants.reject { |participant| participant.user_id == user.id }.map(&:user_id).uniq.count
    else
      session_participants.where.not(user_id: user.id).distinct.count(:user_id)
    end
  end

  def completed?
    status == "COMPLETED"
  end

  def active?
    status == "ACTIVE"
  end
end
