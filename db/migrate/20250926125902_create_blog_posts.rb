class CreateBlogPosts < ActiveRecord::Migration[8.1]
  def change
    create_table :blog_posts do |t|
      t.string :title
      t.string :slug
      t.text :content
      t.text :excerpt
      t.string :status
      t.datetime :published_at
      t.boolean :featured
      t.integer :views_count, default: 0
      t.integer :shares_count, default: 0
      t.integer :reading_time
      t.string :meta_title
      t.string :meta_description
      t.string :meta_keywords
      t.string :canonical_url
      t.references :author, null: false, foreign_key: { to_table: :blog_authors }
      t.references :category, null: true, foreign_key: { to_table: :blog_categories }
      t.string :country_code
      t.string :region
      t.string :city
      t.decimal :latitude
      t.decimal :longitude

      t.timestamps
    end
    add_index :blog_posts, :slug, unique: true
  end
end
