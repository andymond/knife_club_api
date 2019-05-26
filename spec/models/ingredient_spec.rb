require "rails_helper"

describe Ingredient do
  context "relationships" do
    it { should have_many(:recipe_ingredients) }
    it { should have_many(:recipes) }
  end

  context "validations" do
    it { should validate_presence_of(:name) }
  end

end
