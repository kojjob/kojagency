class Project < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: [ :slugged, :history ]

  # Active Storage attachments
  has_one_attached :featured_image
  has_many_attached :gallery_images

  # Associations
  has_many :project_technologies, dependent: :destroy
  has_many :technologies, through: :project_technologies

  has_many :project_services, dependent: :destroy
  has_many :services, through: :project_services

  # Enums
  enum :status, {
    draft: 0,
    published: 1,
    archived: 2
  }

  # Validations
  validates :title, presence: true, length: { maximum: 200 }
  validates :description, presence: true, length: { minimum: 50, maximum: 5000 }
  validates :client_name, presence: true, length: { maximum: 100 }
  validates :status, presence: true
  validates :slug, uniqueness: { case_sensitive: false }

  validates :project_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, allow_blank: true
  validates :github_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: "must be a valid URL" }, allow_blank: true

  validates :duration_months, numericality: { greater_than: 0 }, allow_nil: true
  validates :team_size, numericality: { greater_than: 0 }, allow_nil: true

  # Active Storage validations
  validate :featured_image_format
  validate :gallery_images_format

  # Scopes
  scope :published, -> { where(status: :published) }
  scope :featured, -> { where(featured: true) }
  scope :recent, -> { order(completion_date: :desc, id: :asc) }
  scope :completed_after, ->(date) { where("completion_date > ?", date) }

  # Instance methods
  def display_duration
    return "N/A" if duration_months.nil?

    "#{duration_months} #{duration_months == 1 ? 'month' : 'months'}"
  end

  def display_team_size
    return "N/A" if team_size.nil?

    "#{team_size} #{team_size == 1 ? 'person' : 'people'}"
  end

  def formatted_completion_date
    return "N/A" if completion_date.nil?

    completion_date.strftime("%B %Y")
  end

  private

  def featured_image_format
    return unless featured_image.attached?

    unless featured_image.content_type.in?(%w[image/jpeg image/jpg image/png image/webp])
      errors.add(:featured_image, "must be a JPEG, PNG, or WebP image")
    end

    if featured_image.byte_size > 5.megabytes
      errors.add(:featured_image, "must be less than 5MB")
    end
  end

  def gallery_images_format
    return unless gallery_images.attached?

    gallery_images.each do |image|
      unless image.content_type.in?(%w[image/jpeg image/jpg image/png image/webp])
        errors.add(:gallery_images, "must be JPEG, PNG, or WebP images")
        break
      end

      if image.byte_size > 5.megabytes
        errors.add(:gallery_images, "must each be less than 5MB")
        break
      end
    end

    if gallery_images.count > 10
      errors.add(:gallery_images, "must have 10 or fewer images")
    end
  end
end
