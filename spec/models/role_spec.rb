require "rails_helper"

describe Role do
  context "relationships" do
    it { should have_many(:user_roles) }
    it { should have_many(:users) }
  end
end
