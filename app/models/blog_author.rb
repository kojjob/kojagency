class BlogAuthor < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged

  # Associations
  has_many :blog_posts, as: :author, dependent: :destroy
  has_one_attached :avatar

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :slug, uniqueness: true

  # No need to serialize for PostgreSQL text arrays - it's handled natively

  # Instance Methods
  def display_avatar
    if avatar.attached?
      avatar
    else
      # Gravatar fallback
      "https://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase.strip)}?s=200&d=mp"
    end
  end

  def social_link(platform)
    social_media&.dig(platform.to_s)
  end

  def verified?
    verified
  end

  def profile_url
    Rails.application.routes.url_helpers.blog_author_path(self)
  end

  def posts_count
    blog_posts.count
  end

  def total_views
    blog_posts.sum(:views_count)
  end

  def display_title
    return nil if title.blank? && company.blank?
    [title, company].compact.join(" at ")
  end

  def has_social_media?
    social_media.present? && social_media.values.any?(&:present?)
  end
end