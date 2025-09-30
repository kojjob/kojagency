class BlogCategory < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Associations
  has_many :blog_posts, foreign_key: :category_id, dependent: :nullify
  belongs_to :parent, class_name: "BlogCategory", optional: true
  has_many :subcategories, class_name: "BlogCategory", foreign_key: "parent_id"

  # Validations
  validates :name, presence: true, uniqueness: true
  validates :slug, uniqueness: true

  # Scopes
  scope :top_level, -> { where(parent_id: nil) }
  scope :with_posts, -> {
    joins(:blog_posts)
      .where(blog_posts: { status: "published" })
      .where("blog_posts.published_at <= ?", Time.current)
      .distinct
  }

  # Instance Methods
  def posts_count
    blog_posts.published.count
  end

  def full_path
    ancestors = []
    current = self
    while current
      ancestors.unshift(current.name)
      current = current.parent
    end
    ancestors.join(" > ")
  end
end
