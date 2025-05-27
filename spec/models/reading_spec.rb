require 'rails_helper'

RSpec.describe Reading, type: :model do
  subject { build(:reading) }

  it { is_expected.to validate_uniqueness_of(:book_id).scoped_to(:user_id) }
end
