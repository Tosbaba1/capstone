# == Schema Information
#
# Table name: ai_chat_messages
#
#  id         :bigint           not null, primary key
#  content    :text
#  role       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_ai_chat_messages_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class AiChatMessage < ApplicationRecord
  belongs_to :user
end
