# == Schema Information
#
# Table name: readings
#
#  id         :bigint           not null, primary key
#  is_private :boolean          default(FALSE)
#  progress   :integer
#  rating     :decimal(2, 1)
#  review     :text
#  status     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  book_id    :integer
#  user_id    :integer
#
# Indexes
#
#  index_readings_on_user_id_and_book_id  (user_id,book_id) UNIQUE
#
require 'rails_helper'

RSpec.describe Reading, type: :model do
  subject { build(:reading) }

  it { is_expected.to validate_uniqueness_of(:book_id).scoped_to(:user_id) }
end
