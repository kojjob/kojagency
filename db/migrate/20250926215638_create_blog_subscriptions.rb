class CreateBlogSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :blog_subscriptions do |t|
      t.string :email, null: false
      t.boolean :active, default: true
      t.datetime :confirmed_at

      t.timestamps
    end
    add_index :blog_subscriptions, :email, unique: true
  end
end
