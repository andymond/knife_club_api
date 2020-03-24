# frozen_string_literal: true

class RecipeSerializer < ActiveModel::Serializer
  attributes :id, :name

  belongs_to :section
end
