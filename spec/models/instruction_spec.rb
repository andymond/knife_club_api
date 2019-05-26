require "rails_helper"

describe Instruction do
  context "relationships" do
    it { should belong_to(:recipe) }
  end

  context "validations" do
    it { should validate_presence_of(:text) }
  end
end
