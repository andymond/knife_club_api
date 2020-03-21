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

class Recipe < ApplicationRecord
  include PermissionRecord

  validates_presence_of :name

  belongs_to :section
  has_many :instructions, dependent: :destroy
  has_many :recipe_ingredients, dependent: :destroy
  has_many :user_recipe_roles, dependent: :destroy
  has_many :ingredients, through: :recipe_ingredients
  has_many :users, through: :user_recipe_roles
end
