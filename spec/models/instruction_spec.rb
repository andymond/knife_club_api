# frozen_string_literal: true

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

require 'rails_helper'

describe Instruction do
  context 'relationships' do
    it { is_expected.to belong_to(:recipe) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:text) }
  end
end
