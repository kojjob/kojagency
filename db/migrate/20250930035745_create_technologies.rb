class CreateTechnologies < ActiveRecord::Migration[8.1]
  def change
    create_table :technologies do |t|
      t.string :name, null: false
      t.string :category, null: false
      t.text :description
      t.string :icon_class

      t.timestamps
    end

    add_index :technologies, :name, unique: true
    add_index :technologies, :category
  end
end
