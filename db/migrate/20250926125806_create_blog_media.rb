class CreateBlogMedia < ActiveRecord::Migration[8.1]
  def change
    create_table :blog_media do |t|
      t.string :media_type
      t.string :content_type
      t.integer :file_size
      t.jsonb :metadata
      t.string :alt_text
      t.text :caption

      t.timestamps
    end
  end
end
