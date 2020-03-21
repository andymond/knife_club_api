# == Schema Information
#
# Table name: instructions
#
#  id         :bigint(8)        not null, primary key
#  step       :integer
#  text       :text             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  recipe_id  :bigint(8)
#
# Indexes
#
#  index_instructions_on_recipe_id  (recipe_id)
#
# Foreign Keys
#
#  fk_rails_...  (recipe_id => recipes.id)
#

class Instruction < ApplicationRecord
  validates_presence_of :text

  belongs_to :recipe
end
