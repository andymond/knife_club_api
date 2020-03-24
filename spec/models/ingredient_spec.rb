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

require 'rails_helper'

describe Ingredient do
  context 'relationships' do
    it { is_expected.to have_many(:recipe_ingredients) }
    it { is_expected.to have_many(:recipes) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:name) }
  end
end
