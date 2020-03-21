class RecipeSerializer < ActiveModel::Serializer
  attributes :id, :name

  belongs_to :section
end
