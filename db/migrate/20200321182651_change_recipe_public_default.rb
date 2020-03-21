class ChangeRecipePublicDefault < ActiveRecord::Migration[5.2]
  def up
    change_column_default :recipes, :public, true
  end

  def down
    change_column_default :recipes, :public, false
  end
end
