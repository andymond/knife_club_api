require "rails_helper"

describe User do
  context "relationships" do
    it { should have_one(:api_session) }
    it { should have_many(:user_roles) }
    it { should have_many(:roles) }
    it { should have_many(:cookbooks) }
  end

  context "validations" do
    let(:user) { described_class.new }

    it "validates password" do
      user.password = "xy"
      user.valid?

      expect(user.errors[:password]).to include("is too short (minimum is 3 characters)")
      should validate_presence_of(:password_confirmation)
    end

    it "validates email" do
      should validate_presence_of(:email)
      invalid_email = ["lameemail", "notreal@", "fakecontactinfo.com"].sample
      user.email = invalid_email
      user.valid?

      expect(user.errors[:email]).to include("is invalid")
    end
  end
end
