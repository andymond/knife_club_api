class Instruction < ApplicationRecord
  validates_presence_of :text

  belongs_to :recipe
end
