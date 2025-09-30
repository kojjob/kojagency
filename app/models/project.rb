class Project < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: [:slugged, :history]

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

  validates :project_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: 'must be a valid URL' }, allow_blank: true
  validates :github_url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), message: 'must be a valid URL' }, allow_blank: true

  validates :duration_months, numericality: { greater_than: 0 }, allow_nil: true
  validates :team_size, numericality: { greater_than: 0 }, allow_nil: true

  # Scopes
  scope :published, -> { where(status: :published) }
  scope :featured, -> { where(featured: true) }
  scope :recent, -> { order(completion_date: :desc, id: :asc) }
  scope :completed_after, ->(date) { where('completion_date > ?', date) }

  # Instance methods
  def display_duration
    return 'N/A' if duration_months.nil?

    "#{duration_months} #{duration_months == 1 ? 'month' : 'months'}"
  end

  def display_team_size
    return 'N/A' if team_size.nil?

    "#{team_size} #{team_size == 1 ? 'person' : 'people'}"
  end

  def formatted_completion_date
    return 'N/A' if completion_date.nil?

    completion_date.strftime('%B %Y')
  end
end
