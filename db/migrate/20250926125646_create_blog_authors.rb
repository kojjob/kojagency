class CreateBlogAuthors < ActiveRecord::Migration[8.1]
  def change
    create_table :blog_authors do |t|
      t.string :name
      t.string :email
      t.text :bio
      t.string :website
      t.jsonb :social_media
      t.string :slug

      t.timestamps
    end
    add_index :blog_authors, :slug, unique: true
  end
end
