# == Schema Information
#
# Table name: badges
#
#  id          :bigint           not null, primary key
#  description :string
#  image_url   :string
#  name        :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  user_id     :bigint           not null
#
# Indexes
#
#  index_badges_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Badge < ApplicationRecord
  belongs_to :user
end
