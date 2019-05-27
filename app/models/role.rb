# == Schema Information
#
# Table name: roles
#
#  id         :bigint(8)        not null, primary key
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Role < ApplicationRecord
  has_many :user_roles
  has_many :users, through: :user_roles

  Rails.configuration.user_roles.each do |name|
    define_singleton_method(name) do
      instance_variable_get("@#{name}") ||
      instance_variable_set("@#{name}", find_by(name: name))
    end
  end
end
