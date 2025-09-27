class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :name, null: false
      t.string :password_digest, null: false
      t.boolean :admin, default: false
      t.datetime :confirmed_at

      t.timestamps
    end
    add_index :users, :email, unique: true
  end
end
