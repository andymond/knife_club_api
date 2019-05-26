class Recipe < ApplicationRecord
  validates_presence_of :name

  belongs_to :section
  has_many :instructions
  has_many :recipe_ingredients
  has_many :ingredients, through: :recipe_ingredients
end
