class AllowNullAuthorIdInBlogPosts < ActiveRecord::Migration[8.1]
  def change
    change_column_null :blog_posts, :author_id, true
  end
end
