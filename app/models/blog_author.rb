class BlogAuthor < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Associations
  has_many :blog_posts, as: :author, dependent: :destroy

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :slug, uniqueness: true

  # Instance Methods
  def profile_url
    Rails.application.routes.url_helpers.blog_author_path(self)
  end

  def posts_count
    blog_posts.count
  end
end