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
#  name                   :string
#  posts_count            :integer
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
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

  def random_currently_reading_book
    reading_books
      .joins(:readings)
      .where(readings: { status: 'reading' })
      .order(Arel.sql('RANDOM()'))
      .first
  end

  def timeline
    Post.where(creator_id: following.ids + [id])
  end

  validates :username, uniqueness: true, allow_blank: true

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
