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

  describe 'status change' do
    let(:user) { create(:user) }
    let(:book) { create(:book) }

    it 'creates a post when starting to read' do
      reading = Reading.create(user: user, book: book, status: 'reading')
      expect(Post.last.book).to eq(book)
    end

    it 'creates a post when moving from want_to_read to reading' do
      reading = Reading.create(user: user, book: book, status: 'want_to_read')
      expect do
        reading.update(status: 'reading')
      end.to change(Post, :count).by(1)
    end
  end
end
