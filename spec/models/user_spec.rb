require "rails_helper"

describe User do
  context "relationships" do
    it { should have_one(:api_session) }
    it { should have_many(:user_roles) }
    it { should have_many(:roles) }
  end

  context "validations" do
    it "validates password" do
      user = described_class.new
      user.password = "xy"
      user.valid?
      expect(user.errors[:password]).to include("is too short (minimum is 3 characters)")
      should validate_presence_of(:password_confirmation)
    end

    it "validates email" do
      should validate_presence_of(:email)
    end
  end
end
