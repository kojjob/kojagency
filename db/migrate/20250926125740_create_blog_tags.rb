class CreateBlogTags < ActiveRecord::Migration[8.1]
  def change
    create_table :blog_tags do |t|
      t.string :name
      t.string :slug
      t.integer :usage_count, default: 0

      t.timestamps
    end
    add_index :blog_tags, :slug, unique: true
  end
end
