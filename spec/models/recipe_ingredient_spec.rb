require "rails_helper"

describe RecipeIngredient do
  context "relationships" do
    it { should belong_to(:recipe) }
    it { should belong_to(:ingredient) }
  end

  context "validations" do
    let(:set_invalid_type) { described_class.new.ingredient_type = "invalid type" }
    it "limits accepted ingredient type to enum" do
      expect{ set_invalid_type }.to raise_error(ArgumentError)
    end
  end
end
