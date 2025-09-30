class BlogMediaAttachment < ApplicationRecord
  belongs_to :blog_post
  belongs_to :blog_media
end
