class AddCookbookIdToUserRoles < ActiveRecord::Migration[5.2]
  def change
    add_reference :user_cookbook_roles, :cookbook, foreign_key: true, null: false
  end
end
