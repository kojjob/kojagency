class BlogRelatedPost < ApplicationRecord
  belongs_to :blog_post
  belongs_to :related_post, class_name: 'BlogPost'
end