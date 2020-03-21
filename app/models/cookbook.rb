# == Schema Information
#
# Table name: cookbooks
#
#  id         :bigint(8)        not null, primary key
#  name       :string
#  public     :boolean          default(FALSE)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Cookbook < ApplicationRecord
  include PermissionRecord

  validates_presence_of :name

  has_many :user_cookbook_roles
  has_many :users, through: :user_cookbook_roles
  has_many :sections

  after_create :add_general_section

  def owners
    owner_ids = user_cookbook_roles.where(role: Role.owner).distinct.pluck(:user_id)
    users.where(id: owner_ids)
  end

  def contributors
    contributor_ids = user_cookbook_roles.where(role: Role.contributor).distinct.pluck(:user_id)
    users.where(id: contributor_ids)
  end

  def general_section
    general_name = self.name + " general"
    self.sections.find_by(name: general_name)
  end

  private
    def add_general_section
      general_name = self.name + " general"
      self.sections.create(name: general_name)
    end
end
