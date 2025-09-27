class ConvertBlogPostAuthorToPolymorphic < ActiveRecord::Migration[8.1]
  def up
    # Remove the foreign key constraint first
    remove_foreign_key :blog_posts, :blog_authors

    # Add polymorphic columns
    add_column :blog_posts, :author_type, :string

    # Update existing records to use BlogAuthor as the polymorphic type
    execute "UPDATE blog_posts SET author_type = 'BlogAuthor' WHERE author_id IS NOT NULL"

    # Add index for polymorphic association
    add_index :blog_posts, [:author_type, :author_id]
  end

  def down
    # Remove polymorphic index
    remove_index :blog_posts, [:author_type, :author_id] if index_exists?(:blog_posts, [:author_type, :author_id])

    # Remove polymorphic type column
    remove_column :blog_posts, :author_type

    # Re-add the foreign key constraint
    add_foreign_key :blog_posts, :blog_authors, column: :author_id
  end
end
