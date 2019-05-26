require "rails_helper"

describe Section do
  context "relationships" do
    it { should belong_to(:cookbook) }
    it { should have_many(:recipes) }
  end

  context "validations" do
    it { should validate_presence_of(:name) }
  end
end
