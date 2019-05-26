class RecipeIngredient < ApplicationRecord
  enum ingredient_type: { ingredient: "ingredient", recipe: "recipe", other: "other" }

  belongs_to :recipe
  belongs_to :ingredient
end
