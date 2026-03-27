require "rails_helper"

RSpec.describe FeatureFlags do
  describe "#assignments" do
    it "returns deterministic experiment variants for a given user" do
      user = create(:user)

      first_assignment = described_class.new(user: user).assignments
      second_assignment = described_class.new(user: user).assignments

      expect(first_assignment).to eq(second_assignment)
      expect(first_assignment[:session_type]).to be_in(%w[silent structured])
      expect(first_assignment[:session_length]).to be_in([20, 25, 30])
      expect(first_assignment[:presence_visibility]).to be_in(%w[avatars count_only])
    end
  end
end
