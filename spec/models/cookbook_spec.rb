# == Schema Information
#
# Table name: cookbooks
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  public     :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require "rails_helper"

describe Cookbook do
  let(:cookbook) { create(:cookbook) }

  context "concerns" do
    it "is a permission record" do
      expect(cookbook.role_set).to eq(:user_cookbook_roles)
      expect(cookbook.role_key).to eq(:cookbook)
    end
  end

  context "relationships" do
    it { should have_many(:user_cookbook_roles) }
    it { should have_many(:users) }
    it { should have_many(:sections) }
  end

  context "validations" do
    it { should validate_presence_of(:name) }
  end

  context "callbacks" do
    it "creates 'general' section on create" do
      expect{ cookbook }.to change{ Section.count }.by 1
      expect(cookbook.sections.first.name).to eq(cookbook.name + " general")
    end
  end
end
