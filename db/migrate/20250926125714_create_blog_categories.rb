class CreateBlogCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :blog_categories do |t|
      t.string :name
      t.text :description
      t.references :parent, null: true, foreign_key: { to_table: :blog_categories }
      t.string :slug
      t.integer :post_count, default: 0

      t.timestamps
    end
    add_index :blog_categories, :slug, unique: true
  end
end
