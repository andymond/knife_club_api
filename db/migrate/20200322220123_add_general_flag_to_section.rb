class AddGeneralFlagToSection < ActiveRecord::Migration[5.2]
  def change
    add_column :sections, :general, :boolean, default: false
  end
end
