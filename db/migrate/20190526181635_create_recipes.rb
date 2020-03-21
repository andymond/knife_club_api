class CreateRecipes < ActiveRecord::Migration[5.2]
  def change
    create_table :recipes do |t|
      t.string :name, null: false
      t.boolean :public, default: false
      t.references :section, foreign_key: true, null: false

      t.timestamps
    end
  end
end
