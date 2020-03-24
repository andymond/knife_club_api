# == Schema Information
#
# Table name: recipe_ingredients
#
#  id              :bigint(8)        not null, primary key
#  ingredient_type :enum             default("ingredient"), not null
#  quantity        :integer
#  unit            :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  ingredient_id   :bigint(8)
#  recipe_id       :bigint(8)
#
# Indexes
#
#  index_recipe_ingredients_on_ingredient_id  (ingredient_id)
#  index_recipe_ingredients_on_recipe_id      (recipe_id)
#
# Foreign Keys
#
#  fk_rails_...  (ingredient_id => ingredients.id)
#  fk_rails_...  (recipe_id => recipes.id)
#

class RecipeIngredient < ApplicationRecord
  enum ingredient_type: { ingredient: 'ingredient', recipe: 'recipe', other: 'other' }

  belongs_to :recipe
  belongs_to :ingredient
end
