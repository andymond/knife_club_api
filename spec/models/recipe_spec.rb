require "rails_helper"

describe Recipe do
  context "relationships" do
    it { should belong_to(:section) }
  end

  context "validations" do
    it { should validate_presence_of(:name) }
  end
end
