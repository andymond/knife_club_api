# == Schema Information
#
# Table name: cookbooks
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  public     :boolean          default("false")
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class CookbookSerializer < ActiveModel::Serializer
  attributes :id, :name, :public
end
