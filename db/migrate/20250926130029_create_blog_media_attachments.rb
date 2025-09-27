class CreateBlogMediaAttachments < ActiveRecord::Migration[8.1]
  def change
    create_table :blog_media_attachments do |t|
      t.references :blog_post, null: false, foreign_key: true
      t.references :blog_media, null: false, foreign_key: true

      t.timestamps
    end
  end
end
