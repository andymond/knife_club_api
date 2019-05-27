# == Schema Information
#
# Table name: ingredients
#
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Ingredient < ApplicationRecord
  validates_presence_of :name

  has_many :recipe_ingredients
  has_many :recipes, through: :recipe_ingredients
end
