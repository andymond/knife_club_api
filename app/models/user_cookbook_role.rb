# frozen_string_literal: true

# == Schema Information
#
# Table name: user_cookbook_roles
#
#  id          :bigint(8)        not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  cookbook_id :bigint(8)        not null
#  role_id     :bigint(8)        not null
#  user_id     :bigint(8)        not null
#
# Indexes
#
#  index_user_cookbook_roles_on_cookbook_id  (cookbook_id)
#  index_user_cookbook_roles_on_role_id      (role_id)
#  index_user_cookbook_roles_on_user_id      (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (cookbook_id => cookbooks.id)
#  fk_rails_...  (role_id => roles.id)
#  fk_rails_...  (user_id => users.id)
#

class UserCookbookRole < ApplicationRecord
  belongs_to :user
  belongs_to :cookbook
  belongs_to :role, optional: true
end
