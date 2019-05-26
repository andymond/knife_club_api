require "rails_helper"

describe User do
  context "relationships" do
    it { should have_one(:api_session) }
    it { should have_many(:user_roles) }
    it { should have_many(:roles) }
  end
end
