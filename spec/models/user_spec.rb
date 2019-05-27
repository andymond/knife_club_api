# == Schema Information
#
# Table name: users
#
#  id                                  :bigint(8)        not null, primary key
#  access_count_to_reset_password_page :integer          default(0)
#  crypted_password                    :string
#  email                               :string           not null
#  first_name                          :string
#  last_name                           :string
#  phone_number                        :string
#  reset_password_email_sent_at        :datetime
#  reset_password_token                :string
#  reset_password_token_expires_at     :datetime
#  salt                                :string
#  created_at                          :datetime         not null
#  updated_at                          :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token)
#

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
