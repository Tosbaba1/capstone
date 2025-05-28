require 'rails_helper'

RSpec.describe User, type: :model do
  describe '#explore_feed' do
    it 'excludes self and followed users' do
      user = create(:user)
      followed = create(:user)
      stranger = create(:user)

      create(:followrequest, sender: user, recipient: followed, status: 'accepted')
      create(:followrequest, sender: followed, recipient: stranger, status: 'accepted')

      my_post = create(:post, creator: user)
      followed_post = create(:post, creator: followed)
      stranger_post = create(:post, creator: stranger)

      expect(user.explore_feed).to include(stranger_post)
      expect(user.explore_feed).not_to include(my_post)
      expect(user.explore_feed).not_to include(followed_post)
    end
  end
end
