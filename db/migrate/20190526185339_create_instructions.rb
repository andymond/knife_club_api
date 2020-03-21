class CreateInstructions < ActiveRecord::Migration[5.2]
  def change
    create_table :instructions do |t|
      t.references :recipe, foreign_key: true
      t.integer :step
      t.text :text, null: false

      t.timestamps
    end
  end
end
