# == Schema Information
#
# Table name: posts
#
#  id             :bigint           not null, primary key
#  comments_count :integer
#  content        :text
#  likes_count    :integer
#  poll_data      :jsonb
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  book_id        :integer
#  creator_id     :integer
#
class Post < ApplicationRecord
  #Direct Associations
  belongs_to :creator, required: true, class_name: "User", foreign_key: "creator_id", counter_cache: true
  belongs_to :book, class_name: "Book", foreign_key: "book_id", optional: true
  has_many  :likes, class_name: "Like", foreign_key: "post_id", dependent: :destroy
  has_many  :comments, class_name: "Comment", foreign_key: "post_id", dependent: :destroy
  has_many_attached :media
  has_many :notifications, as: :notifiable, dependent: :destroy

  #Indirect Associations
  has_many :likeds, through: :likes, source: :liked
  has_many :followers, through: :creator, source: :following

  validate :content_present

  after_create :notify_mutuals_about_book

  private

  def content_present
    if content.blank? && book_id.blank? && !media.attached?
      errors.add(:base, "Post cannot be empty")
    end
  end

  def notify_mutuals_about_book
    return unless book

    mutuals = creator.followers & creator.following
    mutuals.each do |user|
      next if user == creator

      if user.posts.where(book_id: book.id, created_at: 30.days.ago..Time.current).exists?
        Notification.create(
          recipient: user,
          actor: creator,
          action: 'started reading the same book as you',
          notifiable: book
        )
      elsif user.posts.where(book_id: book.id).exists?
        Notification.create(
          recipient: user,
          actor: creator,
          action: 'started reading a book you read',
          notifiable: book
        )
      end
    end
  end
end
