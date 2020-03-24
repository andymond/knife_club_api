# frozen_string_literal: true

module PermissionRecord
  include ActiveSupport::Concern

  def role_set
    "user_#{formatted_class_name}_roles".to_sym
  end

  def role_key
    formatted_class_name.to_sym
  end

  def formatted_class_name
    self.class.name.downcase.underscore
  end
end
