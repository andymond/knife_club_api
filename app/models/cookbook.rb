class Cookbook < ApplicationRecord
  validates_presence_of :name

  has_many :user_roles
  has_many :users, through: :user_roles
  has_many :sections
end
