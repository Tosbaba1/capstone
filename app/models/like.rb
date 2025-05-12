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
end
