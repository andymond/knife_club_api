# frozen_string_literal: true

class SectionSerializer < ActiveModel::Serializer
  attributes :id, :name

  belongs_to :cookbook
  has_many :recipes
end
