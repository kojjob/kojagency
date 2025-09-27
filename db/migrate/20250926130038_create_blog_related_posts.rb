class CreateBlogRelatedPosts < ActiveRecord::Migration[8.1]
  def change
    create_table :blog_related_posts do |t|
      t.references :blog_post, null: false, foreign_key: true
      t.references :related_post, null: false, foreign_key: { to_table: :blog_posts }

      t.timestamps
    end
  end
end
