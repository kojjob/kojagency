class BlogPost < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged

  # For rich text editor
  has_rich_text :rich_content

  # Geocoding
  geocoded_by :location_string
  after_validation :geocode, if: :location_changed?

  # Associations
  belongs_to :author, polymorphic: true
  belongs_to :category, class_name: 'BlogCategory', optional: true
  has_many :blog_post_tags, dependent: :destroy
  has_many :tags, through: :blog_post_tags, source: :blog_tag
  has_many :blog_media_attachments, dependent: :destroy
  has_many :media, through: :blog_media_attachments, source: :blog_media
  has_many :blog_related_posts, dependent: :destroy
  has_many :related_posts, through: :blog_related_posts, source: :related_post
  has_many :blog_comments, dependent: :destroy
  has_many :approved_comments, -> { approved.root_comments }, class_name: 'BlogComment'
  has_one_attached :featured_image

  # Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :content, presence: true
  validates :slug, uniqueness: true
  validates :meta_description, length: { maximum: 160 }, allow_blank: true
  validates :meta_title, length: { maximum: 60 }, allow_blank: true
  validates :status, inclusion: { in: %w[draft published scheduled archived] }
  validates :country_code, length: { is: 2 }, allow_blank: true

  # Callbacks
  before_validation :generate_slug
  before_save :calculate_reading_time
  before_save :set_published_at

  # Scopes
  scope :published, -> {
    where(status: 'published')
      .where('published_at <= ?', Time.current)
  }
  scope :scheduled, -> {
    where(status: 'scheduled')
      .or(where(status: 'published').where('published_at > ?', Time.current))
  }
  scope :draft, -> { where(status: 'draft') }
  scope :archived, -> { where(status: 'archived') }
  scope :recent, -> { order(Arel.sql('COALESCE(blog_posts.published_at, blog_posts.created_at) DESC')) }
  scope :popular, -> { order(views_count: :desc, shares_count: :desc) }
  scope :featured, -> { where(featured: true) }

  # GEO scopes
  scope :in_country, ->(code) { where(country_code: code) }
  scope :in_region, ->(region) { where(region: region) }
  scope :in_city, ->(city) { where(city: city) }

  # Sitemap and trending
  scope :for_sitemap, -> { published }
  scope :trending, ->(weeks = 1) {
    published
      .where('published_at >= ?', weeks.weeks.ago)
      .order(Arel.sql('(views_count * 0.6 + shares_count * 0.4) DESC'))
  }

  # Instance Methods
  def seo_title
    meta_title.presence || title
  end

  def seo_description
    meta_description.presence || excerpt.presence || content.truncate(160)
  end

  def structured_data
    {
      "@context": "https://schema.org",
      "@type": "Article",
      "headline": title,
      "description": seo_description,
      "author": {
        "@type": "Person",
        "name": author.name
      },
      "datePublished": published_at&.iso8601,
      "dateModified": updated_at.iso8601,
      "publisher": {
        "@type": "Organization",
        "name": "Koj Agency"
      },
      "mainEntityOfPage": {
        "@type": "WebPage",
        "@id": canonical_url_with_fallback
      }
    }.to_json
  end

  def canonical_url_with_fallback
    canonical_url.presence || Rails.application.routes.url_helpers.blog_post_url(self, host: Rails.application.config.action_mailer.default_url_options[:host])
  end

  def publish!
    update!(status: 'published', published_at: published_at || Time.current)
  end

  def archive!
    update!(status: 'archived')
  end

  def published?
    status == 'published' && published_at.present? && published_at <= Time.current
  end

  def scheduled?
    status == 'scheduled' || (status == 'published' && published_at.present? && published_at > Time.current)
  end

  def draft?
    status == 'draft'
  end

  def archived?
    status == 'archived'
  end

  def increment_views!
    increment!(:views_count)
  end

  # Media helpers
  def images
    media.images
  end

  def videos
    media.videos
  end

  def documents
    media.documents
  end

  private

  def generate_slug
    if slug.blank? && title.present?
      self.slug = title.parameterize
    end
  end

  def calculate_reading_time
    if content.present?
      words_per_minute = 250
      word_count = content.split.size
      self.reading_time = (word_count.to_f / words_per_minute).ceil
    end
  end

  def set_published_at
    if status == 'published' && published_at.blank?
      self.published_at = Time.current
    end
  end

  def location_string
    [city, region, country_code].compact.join(', ')
  end

  def location_changed?
    city_changed? || region_changed? || country_code_changed?
  end
end