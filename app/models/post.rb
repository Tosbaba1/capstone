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
end
