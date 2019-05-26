class Section < ApplicationRecord
  belongs_to :cookbook
  has_many :recipes
end
