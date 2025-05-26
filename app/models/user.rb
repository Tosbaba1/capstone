# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  avatar                 :string
#  bio                    :text
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
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

  #Indirect Associations
  has_many :following, through: :sentfollowrequests, source: :recipient

  has_many :followers, through: :receivedfollowrequests, source: :sender

  has_many :books, through: :posts, source: :book

  has_many :liked_posts, through: :likes, source: :post

  has_many :feed, through: :following, source: :posts

  # Posts from people your followings follow
  has_many :extended_following, through: :following, source: :following
  has_many :explore_feed, through: :extended_following, source: :posts
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
