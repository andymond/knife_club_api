# == Schema Information
#
# Table name: user_recipe_roles
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  recipe_id  :bigint(8)
#  role_id    :bigint(8)
#  user_id    :bigint(8)
#
# Indexes
#
#  index_user_recipe_roles_on_recipe_id  (recipe_id)
#  index_user_recipe_roles_on_role_id    (role_id)
#  index_user_recipe_roles_on_user_id    (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (recipe_id => recipes.id)
#  fk_rails_...  (role_id => roles.id)
#  fk_rails_...  (user_id => users.id)
#
class UserRecipeRole < ApplicationRecord
  belongs_to :user
  belongs_to :role, optional: true
  belongs_to :recipe
end
