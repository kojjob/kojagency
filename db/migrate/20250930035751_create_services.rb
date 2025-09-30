class CreateServices < ActiveRecord::Migration[8.1]
  def change
    create_table :services do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description, null: false
      t.string :icon_class
      t.text :features

      t.timestamps
    end

    add_index :services, :slug, unique: true
  end
end
