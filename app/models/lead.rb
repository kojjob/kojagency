class Lead < ApplicationRecord
  # Associations
  has_many :analytics, dependent: :destroy
  has_many :conversion_events, dependent: :destroy
  has_many :email_sequences, dependent: :destroy
  has_many :crm_syncs, dependent: :destroy

  # Enums for status management
  enum :lead_status, {
    pending: 0,
    contacted: 1,
    qualified: 2,
    proposal_sent: 3,
    negotiating: 4,
    won: 5,
    lost: 6,
    unqualified: 7
  }

  # Validations
  validates :first_name, presence: true, length: { maximum: 50 }
  validates :last_name, presence: true, length: { maximum: 50 }
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :phone, format: { with: /\A[\+]?[1-9][\d\s\-\(\)]*\z/, message: "must be a valid phone number" }, allow_blank: true
  validates :company, length: { maximum: 100 }
  validates :project_type, presence: true, inclusion: { in: %w[web_development mobile_development data_engineering analytics_platform technical_consulting other] }
  validates :budget, presence: true, inclusion: { in: %w[under_10k 10k_25k 25k_50k 50k_100k 100k_250k 250k_plus] }
  validates :timeline, presence: true, inclusion: { in: %w[asap 1_month 3_months 6_months 1_year flexible] }
  validates :project_description, presence: true, length: { minimum: 20, maximum: 2000 }
  validates :source, presence: true
  validates :preferred_contact_method, inclusion: { in: %w[email phone both] }
  validates :score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  # Scopes
  scope :high_priority, -> { where("score >= ?", 80) }
  scope :medium_priority, -> { where("score >= ? AND score < ?", 60, 80) }
  scope :low_priority, -> { where("score < ?", 60) }
  scope :recent, -> { order(created_at: :desc) }
  scope :uncontacted, -> { where(contacted_at: nil) }
  scope :by_source, ->(source) { where(source: source) }
  scope :by_project_type, ->(type) { where(project_type: type) }
  scope :by_budget_range, ->(budget) { where(budget: budget) }

  # Callbacks
  before_save :calculate_score
  after_create :send_new_lead_notification
  after_update :update_contacted_status

  # Instance methods
  def full_name
    "#{first_name} #{last_name}"
  end

  def priority_level
    case score
    when 80..100
      "high"
    when 60...80
      "medium"
    else
      "low"
    end
  end

  def priority_color
    case priority_level
    when "high"
      "text-red-600 bg-red-100"
    when "medium"
      "text-yellow-600 bg-yellow-100"
    else
      "text-green-600 bg-green-100"
    end
  end

  def budget_range_display
    case budget
    when "under_10k"
      "Under $10,000"
    when "10k_25k"
      "$10,000 - $25,000"
    when "25k_50k"
      "$25,000 - $50,000"
    when "50k_100k"
      "$50,000 - $100,000"
    when "100k_250k"
      "$100,000 - $250,000"
    when "250k_plus"
      "$250,000+"
    else
      budget.humanize
    end
  end

  def timeline_display
    case timeline
    when "asap"
      "ASAP"
    when "1_month"
      "1 Month"
    when "3_months"
      "3 Months"
    when "6_months"
      "6 Months"
    when "1_year"
      "1 Year"
    when "flexible"
      "Flexible"
    else
      timeline.humanize
    end
  end

  def project_type_display
    case project_type
    when "web_development"
      "Web Development"
    when "mobile_development"
      "Mobile Development"
    when "data_engineering"
      "Data Engineering"
    when "analytics_platform"
      "Analytics Platform"
    when "technical_consulting"
      "Technical Consulting"
    else
      project_type.humanize
    end
  end

  def response_time_target
    case priority_level
    when "high"
      "Immediate (within 1 hour)"
    when "medium"
      "Priority (within 2 hours)"
    else
      "Standard (within 24 hours)"
    end
  end

  def mark_as_contacted!
    update!(contacted_at: Time.current, lead_status: "contacted")
  end

  def mark_as_qualified!
    update!(qualified_at: Time.current, lead_status: "qualified")
  end

  def days_since_creation
    (Time.current - created_at) / 1.day
  end

  def overdue_response?
    return false if contacted_at.present?

    case priority_level
    when "high"
      days_since_creation > 0.04 # 1 hour
    when "medium"
      days_since_creation > 0.08 # 2 hours
    else
      days_since_creation > 1 # 24 hours
    end
  end

  private

  def calculate_score
    service = LeadScoringService.new(self)
    self.score = service.calculate_total_score
    self.budget_score = service.budget_score
    self.timeline_score = service.timeline_score
    self.complexity_score = service.complexity_score
    self.quality_score = service.quality_score
  end

  def send_new_lead_notification
    # Send notification to admin team asynchronously
    LeadNotificationMailer.new_lead_notification(self).deliver_later
  end

  def update_contacted_status
    if contacted_at_changed? && contacted_at.present? && lead_status == "pending"
      self.update_column(:lead_status, "contacted")
    end
  end
end
