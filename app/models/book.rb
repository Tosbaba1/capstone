# == Schema Information
#
# Table name: books
#
#  id          :bigint           not null, primary key
#  description :text
#  genre       :string
#  image_url   :string
#  page_length :integer
#  title       :string
#  year        :integer
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  author_id   :integer
#  library_id  :integer
#
class Book < ApplicationRecord
  # Validations
  validates :title, presence: true
  validates :author, presence: true
  validates :page_length, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :year, numericality: { only_integer: true }, allow_nil: true

  #Direct Associations
  has_many  :posts, class_name: "Post", foreign_key: "book_id", dependent: :nullify

  has_many :readings, dependent: :destroy
  has_many :users, through: :readings

  belongs_to :author, required: true, class_name: "Author", foreign_key: "author_id", counter_cache: true

  #Indirect Associations
  has_many :readers, through: :posts, source: :creator
end
