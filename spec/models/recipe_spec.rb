# frozen_string_literal: true

# == Schema Information
#
# Table name: recipes
#
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  public     :boolean          default("true")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  section_id :bigint(8)        not null
#
# Indexes
#
#  index_recipes_on_section_id  (section_id)
#
# Foreign Keys
#
#  fk_rails_...  (section_id => sections.id)
#

require 'rails_helper'

describe Recipe do
  let(:recipe) { create(:recipe) }

  context 'concerns' do
    context 'concerns' do
      it 'is a permission record' do
        expect(recipe.role_set).to eq(:user_recipe_roles)
        expect(recipe.role_key).to eq(:recipe)
      end
    end
  end

  context 'relationships' do
    let!(:cool_chef) { create(:user) }
    let!(:doomed_recipe) { create(:recipe) }
    let!(:ingredient) { doomed_recipe.ingredients.create(name: 'Lime') }
    let!(:doomed_instruction) { doomed_recipe.instructions.create(step: 1, text: 'Test') }

    it { is_expected.to belong_to(:section) }
    it { is_expected.to have_many(:instructions) }
    it { is_expected.to have_many(:recipe_ingredients) }
    it { is_expected.to have_many(:ingredients) }

    it 'destroys its user roles, ingredient joins and instructions' do
      cool_chef.grant_all_access(doomed_recipe)

      doomed_recipe.destroy
      disgraced_chef = cool_chef.reload

      expect { doomed_recipe.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(ingredient.reload.recipe_ingredients.any?).to eq(false)
      expect { doomed_instruction.reload }.to raise_error ActiveRecord::RecordNotFound
      expect(disgraced_chef.user_recipe_roles.any?).to eq(false)
    end
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end
end
