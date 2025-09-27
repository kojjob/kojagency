class EnhanceBlogPosts < ActiveRecord::Migration[8.1]
  def change
    # Add hero style options
    add_column :blog_posts, :hero_style, :integer, default: 0

    # Add content layout options
    add_column :blog_posts, :content_layout, :integer, default: 0

    # Content images will be handled by Active Storage (has_many_attached)
    # Featured image already exists
  end
end
