class RenameUserRolesToUserCookbookRoles < ActiveRecord::Migration[5.2]
  def up
    rename_table :user_cookbook_roles, :user_cookbook_roles
  end

  def down
    rename_table :user_cookbook_roles, :user_cookbook_roles
  end
end
