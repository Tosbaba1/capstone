# == Schema Information
#
# Table name: comments
#
#  id           :bigint           not null, primary key
#  comment      :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  commenter_id :integer
#  post_id      :integer
#
class Comment < ApplicationRecord
  belongs_to :commenter, required: true, class_name: "User", foreign_key: "commenter_id"
  belongs_to :post, required: true, class_name: "Post", foreign_key: "post_id", counter_cache: true
end
