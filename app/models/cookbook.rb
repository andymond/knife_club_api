class Cookbook < ApplicationRecord
  validates_presence_of :name

  has_many :user_roles
  has_many :users, through: :user_roles
  has_many :sections

  after_create :add_general_section

  private
    def add_general_section
      general_name = self.name + " general"
      self.sections.create(name: general_name)
    end
end
