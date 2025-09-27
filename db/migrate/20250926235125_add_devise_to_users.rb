# frozen_string_literal: true

class AddDeviseToUsers < ActiveRecord::Migration[8.1]
  def self.up
    change_table :users do |t|
      ## Database authenticatable
      # Email field already exists, just add encrypted_password
      t.string :encrypted_password, null: false, default: ""

      ## Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Role for admin functionality
      t.integer :role, default: 0, null: false

      # Remove password_digest column from has_secure_password since we're using Devise
      t.remove :password_digest, type: :string
    end

    # Email index already exists, just add the new ones
    add_index :users, :reset_password_token, unique: true
    add_index :users, :role
  end

  def self.down
    # By default, we don't want to make any assumption about how to roll back a migration when your
    # model already existed. Please edit below which fields you would like to remove in this migration.
    raise ActiveRecord::IrreversibleMigration
  end
end
