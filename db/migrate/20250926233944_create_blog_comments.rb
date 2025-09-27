class CreateBlogComments < ActiveRecord::Migration[8.1]
  def change
    create_table :blog_comments do |t|
      t.references :blog_post, null: false, foreign_key: true
      t.string :author_name, null: false
      t.string :author_email, null: false
      t.text :content, null: false
      t.integer :status, default: 0, null: false
      t.references :parent, foreign_key: { to_table: :blog_comments }, null: true
      t.string :author_website

      t.timestamps
    end

    add_index :blog_comments, :status
    add_index :blog_comments, :created_at
  end
end
