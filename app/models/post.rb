# == Schema Information
#
# Table name: posts
#
#  id             :bigint           not null, primary key
#  comments_count :integer
#  content        :text
#  likes_count    :integer
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  book_id        :integer
#  creator_id     :integer
#
class Post < ApplicationRecord
  #Direct Associations
  belongs_to :creator, required: true, class_name: "User", foreign_key: "creator_id", counter_cache: true
  belongs_to :book, class_name: "Book", foreign_key: "book_id", counter_cache: true
  has_many  :likes, class_name: "Like", foreign_key: "post_id", dependent: :destroy
  has_many  :comments, class_name: "Comment", foreign_key: "post_id", dependent: :destroy

  #Indirect Associations
  has_many :likeds, through: :likes, source: :liked
  has_many :followers, through: :creator, source: :following
end
