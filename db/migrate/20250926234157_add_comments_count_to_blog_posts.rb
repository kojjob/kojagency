class AddCommentsCountToBlogPosts < ActiveRecord::Migration[8.1]
  def change
    add_column :blog_posts, :blog_comments_count, :integer, default: 0, null: false
  end
end
