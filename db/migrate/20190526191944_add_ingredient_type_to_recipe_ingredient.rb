class AddIngredientTypeToRecipeIngredient < ActiveRecord::Migration[5.2]
  def up
    execute <<-SQL
      CREATE TYPE ingredient_type AS ENUM ('recipe', 'ingredient', 'other');
    SQL
    add_column :recipe_ingredients, :ingredient_type, :ingredient_type, default: "ingredient", null: false
  end

  def down
    remove_column :recipes, :ingredient_type
    execute <<-SQL
      DROP TYPE ingredient_type;
    SQL
  end
end
