class BlogTag < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Associations
  has_many :blog_post_tags, dependent: :destroy
  has_many :posts, through: :blog_post_tags, source: :blog_post

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }
  validates :slug, uniqueness: true

  # Callbacks
  before_save :normalize_name

  # Scopes
  scope :popular, -> { order(usage_count: :desc) }
  scope :used, -> { where('usage_count > 0') }

  # Instance Methods
  def update_usage_count
    update(usage_count: blog_post_tags.count)
  end

  private

  def normalize_name
    self.name = name.strip if name.present?
    self.slug = slug.downcase if slug.present?
  end
end