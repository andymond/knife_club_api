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
end
