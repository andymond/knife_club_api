class SectionSerializer < ActiveModel::Serializer
  attributes :id, :name

  belongs_to :cookbook
end
