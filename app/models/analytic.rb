class Analytic < ApplicationRecord
  # Associations
  belongs_to :lead

  # Validations
  validates :event_type, presence: true
  validates :event_type, inclusion: {
    in: %w[page_view form_start form_submit email_open email_click conversion contact],
    message: "%{value} is not a valid event type"
  }

  # Scopes
  scope :by_event_type, ->(event_type) { where(event_type: event_type) }
  scope :by_source, ->(source) { where(source: source) }
  scope :by_campaign, ->(campaign) { where(campaign: campaign) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_date_range, ->(start_date, end_date) { where(created_at: start_date..end_date) }
  scope :this_week, -> { where('created_at >= ?', 1.week.ago) }
  scope :this_month, -> { where('created_at >= ?', 1.month.ago) }
  scope :this_year, -> { where('created_at >= ?', 1.year.ago) }

  # Class methods
  def self.event_types
    %w[page_view form_start form_submit email_open email_click conversion contact]
  end

  def self.funnel_metrics
    {
      page_views: where(event_type: 'page_view').count,
      form_starts: where(event_type: 'form_start').count,
      form_submits: where(event_type: 'form_submit').count,
      conversions: where(event_type: 'conversion').count
    }
  end

  def self.source_breakdown
    group(:source).count.sort_by { |_, count| -count }
  end

  def self.campaign_performance
    group(:campaign).count.sort_by { |_, count| -count }
  end

  # Instance methods
  def utm_params
    {
      source: source,
      medium: medium,
      campaign: campaign
    }.compact
  end
end
