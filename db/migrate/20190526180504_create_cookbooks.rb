class CreateCookbooks < ActiveRecord::Migration[5.2]
  def change
    create_table :cookbooks do |t|
      t.string :name
      t.boolean :public, default: false

      t.timestamps
    end
  end
end
