# == Schema Information
#
# Table name: users
#
#  id                                  :bigint(8)        not null, primary key
#  access_count_to_reset_password_page :integer          default("0")
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
    it { should have_many(:user_cookbook_roles) }
    it { should have_many(:user_recipe_roles) }
    it { should have_many(:cookbook_roles) }
    it { should have_many(:recipe_roles) }
    it { should have_many(:cookbooks) }
    it { should have_many(:recipes) }
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

  context "instance methods" do
    let(:owner) { create(:user) }
    let!(:cookbook) { owner.create_permission_record(Cookbook, { name: "Icy Delicacies" }) }

    describe "#create_cookbook" do
      it "creates a cook book w/ proper relationship" do
        expect(owner.cookbooks).to include(cookbook)
        expect(owner.user_cookbook_roles.where(cookbook: cookbook, role: Role.owner).count).to eq(1)
      end
    end

    describe "#can_read?(cookbook)" do
      it "returns true if user has any relation to private cookbook" do
        expect(owner.can_read?(cookbook)).to eq(true)
      end

      it "returns false if user does not have relationship to private cookbook" do
        rando = create(:user)
        expect(rando.can_read?(cookbook)).to eq(false)
      end
    end

    describe "#can_update?(cookbook)" do
      it "returns true if user has contribute role for cookbook" do
        contributor = create(:user)
        contributor.allow_contributions_to(cookbook)

        reader = create(:user)
        reader.allow_to_read(cookbook)

        expect(contributor.can_update?(cookbook)).to eq(true)
        expect(owner.can_update?(cookbook)).to eq(true)
      end


      it "returns false if user does not have contribute role for cookbook" do
        rando = create(:user)
        expect(rando.can_update?(cookbook)).to eq(false)
      end
    end


    describe "#owns?(cookbook)" do
      it "returns true if user has owner role for cookbook" do
        expect(owner.owns?(cookbook)).to eq(true)
      end


      it "returns false if user does not have contribute role for cookbook" do
        contributor = create(:user)
        contributor.allow_contributions_to(cookbook)

        reader = create(:user)
        reader.allow_to_read(cookbook)

        rando = create(:user)

        expect(contributor.owns?(cookbook)).to eq(false)
        expect(reader.owns?(cookbook)).to eq(false)
        expect(rando.owns?(cookbook)).to eq(false)
      end
    end


    describe "#allow_to_read(cookbook)" do
      it "grants reader role to user" do
        reader = create(:user)
        expect{ reader.allow_to_read(cookbook) }.to change{ reader.user_cookbook_roles.where(cookbook: cookbook, role: Role.reader ).count }.by 1
      end
    end

    describe "#allow_contributions_to(cookbook)?" do
      it "grants contribution role to user" do
        contributor = create(:user)
        expect{ contributor.allow_contributions_to(cookbook) }.to change{ contributor.user_cookbook_roles.where(cookbook: cookbook, role: Role.contributor).count }.by 1
      end
    end
  end
end
