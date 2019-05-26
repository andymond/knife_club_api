class Recipe < ApplicationRecord
  validates_presence_of :name
  
  belongs_to :section
end
