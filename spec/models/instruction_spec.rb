require "rails_helper"

describe Instruction do
  context "relationships" do
    it { should belong_to(:recipe) }
  end
end
