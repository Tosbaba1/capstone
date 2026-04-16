# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  avatar                 :string
#  banner                 :string
#  bio                    :text
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  is_private             :boolean          default(FALSE)
#  preferred_genres       :text             default([])
#  name                   :string
#  posts_count            :integer
#  reading_frequency      :string
#  recommendation_onboarding_completed_at :datetime
#  recommendation_onboarding_skipped_at   :datetime
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  social_reading_preference :string
#  username               :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  ONBOARDING_GENRE_OPTIONS = [
    "Literary fiction",
    "Romance",
    "Mystery",
    "Fantasy",
    "Science fiction",
    "Memoir",
    "History",
    "Essays"
  ].freeze

  READING_FREQUENCY_OPTIONS = [
    "daily",
    "a_few_times_a_week",
    "weekly",
    "whenever_i_can"
  ].freeze

  SOCIAL_READING_PREFERENCE_OPTIONS = [
    "mostly_solo",
    "a_mix_of_both",
    "mostly_social"
  ].freeze

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  #Direct Associations
  has_many :likes, class_name: "Like", foreign_key: "liked_id", dependent: :destroy

  has_many :comments, class_name: "Comment", foreign_key: "commenter_id", dependent: :destroy

  has_many :sentfollowrequests, class_name: "Followrequest", foreign_key: "sender_id", dependent: :destroy

  has_many :receivedfollowrequests, class_name: "Followrequest", foreign_key: "recipient_id", dependent: :destroy

  has_many :posts, class_name: "Post", foreign_key: "creator_id", dependent: :destroy

  has_many :readings, dependent: :destroy
  has_many :reading_books, through: :readings, source: :book
  has_many :hosted_sessions, class_name: "Session", foreign_key: :host_user_id, inverse_of: :host_user, dependent: :destroy
  has_many :session_participants, dependent: :destroy
  has_many :reading_sessions, through: :session_participants, source: :session
  has_many :badges, dependent: :destroy
  has_many :renous, dependent: :destroy
  has_many :renoued_posts, through: :renous, source: :post
  has_many :ai_chat_messages, dependent: :destroy

  #Indirect Associations
  has_many :following, -> { where(followrequests: { status: 'accepted' }) }, through: :sentfollowrequests, source: :recipient

  has_many :followers, -> { where(followrequests: { status: 'accepted' }) }, through: :receivedfollowrequests, source: :sender

  has_many :books, through: :posts, source: :book

  has_many :liked_posts, through: :likes, source: :post

  has_many :feed, through: :following, source: :posts

  # Posts from people followed by your followings
  # Excludes posts from yourself and people you already follow
  has_many :extended_following, through: :following, source: :following
  has_many :explore_feed,
           ->(user) {
             joins(:creator)
               .where(users: { is_private: false })
               .where.not(creator_id: user.following.ids + [user.id])
               .distinct
           },
           through: :extended_following,
           source: :posts

  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy
  has_many :active_notifications, class_name: 'Notification', foreign_key: :actor_id, dependent: :destroy
  has_many :search_histories, dependent: :destroy

  scope :publicly_visible, -> { where(is_private: false) }

  serialize :preferred_genres, coder: JSON, type: Array

  def preferred_genres
    super || []
  end

  def random_currently_reading_book
    reading_books
      .joins(:readings)
      .where(readings: { status: 'reading', is_private: false })
      .order(Arel.sql('RANDOM()'))
      .first
  end

  def timeline
    Post.where(creator_id: following.ids + [id])
  end

  validates :name, presence: true, on: :update
  validates :username, presence: true, uniqueness: true, on: :update
  validates :reading_frequency, inclusion: { in: READING_FREQUENCY_OPTIONS }, allow_blank: true
  validates :social_reading_preference, inclusion: { in: SOCIAL_READING_PREFERENCE_OPTIONS }, allow_blank: true

  before_validation :downcase_email
  before_validation :normalize_preferred_genres

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def active_session_participant
    session_participants
      .joins(:session)
      .merge(Session.active)
      .where(leave_time: nil)
      .order("sessions.created_at DESC")
      .first
  end

  def completed_session_participants_scope
    session_participants
      .completed
      .includes(:session)
      .where.not(leave_time: nil)
  end

  def completed_session_count
    completed_session_participants_scope.count
  end

  def reading_sessions_this_week(reference_time: Time.current)
    completed_session_participants_scope.where(leave_time: week_range(reference_time)).count
  end

  def reading_time_this_week(reference_time: Time.current)
    reading_time_for_range(week_range(reference_time))
  end

  def current_reading_streak(reference_date: Time.zone.today)
    completed_dates = completed_session_participants_scope
      .where("leave_time <= ?", reference_date.end_of_day)
      .pluck(:leave_time)
      .map { |time| time.in_time_zone.to_date }
      .uniq

    return 0 if completed_dates.empty?

    expected_date = if completed_dates.include?(reference_date)
      reference_date
    elsif completed_dates.include?(reference_date - 1)
      reference_date - 1
    else
      return 0
    end

    streak = 0

    while completed_dates.include?(expected_date)
      streak += 1
      expected_date -= 1
    end

    streak
  end

  def latest_completed_session_participant
    completed_session_participants_scope.order(leave_time: :desc).first
  end

  def recommendation_onboarding_complete?
    recommendation_onboarding_completed_at.present?
  end

  def recommendation_onboarding_skipped?
    recommendation_onboarding_skipped_at.present?
  end

  def recommendation_onboarding_pending?
    !recommendation_onboarding_complete? && !recommendation_onboarding_skipped?
  end

  private

  def downcase_email
    self.email = email.downcase if email.present?
  end

  def normalize_preferred_genres
    self.preferred_genres = Array(preferred_genres)
      .map(&:presence)
      .compact
      .select { |genre| ONBOARDING_GENRE_OPTIONS.include?(genre) }
      .uniq
  end

  def reading_time_for_range(range)
    completed_session_participants_scope.where(leave_time: range).to_a.sum(&:credited_seconds)
  end

  def week_range(reference_time)
    local_time = reference_time.in_time_zone
    local_time.beginning_of_week..local_time.end_of_week
  end
end
