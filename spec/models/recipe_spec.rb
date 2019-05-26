require "rails_helper"

describe Recipe do
  context "relationships" do
    it { should belong_to(:section) }
    it { should have_many(:instructions) }
    it { should have_many(:recipe_ingredients) }
    it { should have_many(:ingredients) }
  end

  context "validations" do
    it { should validate_presence_of(:name) }
  end
end
