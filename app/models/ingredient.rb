# frozen_string_literal: true

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
  validates :name, presence: true

  has_many :recipe_ingredients, dependent: :nullify
  has_many :recipes, through: :recipe_ingredients
end
