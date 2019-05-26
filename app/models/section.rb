class Section < ApplicationRecord
  validates_presence_of :name

  belongs_to :cookbook
  has_many :recipes
end
