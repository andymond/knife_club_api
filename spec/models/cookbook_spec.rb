require "rails_helper"

describe Cookbook do
  context "relationships" do
    it { should have_many(:user_roles) }
    it { should have_many(:users) }
    it { should have_many(:sections) }
  end

  context "validations" do
    it { should validate_presence_of(:name) }
  end

  context "callbacks" do
    let(:cookbook) { create(:cookbook) }

    it "creates 'general' section on create" do
      expect{ cookbook }.to change{ Section.count }.by 1
      expect(cookbook.sections.first.name).to eq(cookbook.name + " general")
    end
  end
end
