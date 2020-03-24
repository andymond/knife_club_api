# frozen_string_literal: true

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
  has_many :user_cookbook_roles
  has_many :cookbook_users, through: :user_cookbook_roles, foreign_key: 'user_id', class_name: 'User'

  Rails.configuration.roles.each do |name|
    define_singleton_method(name) do
      instance_variable_get("@#{name}") ||
        instance_variable_set("@#{name}", find_by(name: name))
    end
  end

  Rails.configuration.roles.each do |name|
    define_method(name + '?') do
      self.name == name
    end
  end
end
