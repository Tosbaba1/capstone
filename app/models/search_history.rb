# == Schema Information
#
# Table name: search_histories
#
#  id         :bigint           not null, primary key
#  query      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_search_histories_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class SearchHistory < ApplicationRecord
  belongs_to :user

  validates :query, presence: true
end
