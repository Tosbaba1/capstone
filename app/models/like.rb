# == Schema Information
#
# Table name: likes
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  liked_id   :integer
#  post_id    :integer
#
class Like < ApplicationRecord
  belongs_to :liked, required: true, class_name: "User", foreign_key: "liked_id"
  belongs_to :post, required: true, class_name: "Post", foreign_key: "post_id", counter_cache: true
end
