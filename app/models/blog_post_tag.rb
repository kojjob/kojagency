class BlogPostTag < ApplicationRecord
  belongs_to :blog_post
  belongs_to :blog_tag

  # Callbacks
  after_create :update_tag_usage_count
  after_destroy :update_tag_usage_count

  private

  def update_tag_usage_count
    blog_tag.update_usage_count if blog_tag.present?
  end
end