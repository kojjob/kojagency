class ConversionEvent < ApplicationRecord
  # Associations
  belongs_to :lead

  # Validations
  validates :event_name, presence: true
  validates :event_name, inclusion: {
    in: %w[lead_contacted lead_qualified proposal_sent deal_won],
    message: "%{value} is not a valid conversion event"
  }
  validates :time_to_convert, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates :value, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  # Scopes
  scope :by_event_name, ->(event_name) { where(event_name: event_name) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_date_range, ->(start_date, end_date) { where(created_at: start_date..end_date) }
  scope :this_week, -> { where("created_at >= ?", 1.week.ago) }
  scope :this_month, -> { where("created_at >= ?", 1.month.ago) }
  scope :this_year, -> { where("created_at >= ?", 1.year.ago) }
  scope :with_value, -> { where.not(value: nil) }

  # Callbacks
  before_create :calculate_time_to_convert

  # Class methods
  def self.event_names
    %w[lead_contacted lead_qualified proposal_sent deal_won]
  end

  def self.conversion_metrics
    {
      total_conversions: count,
      total_value: sum(:value),
      average_value: average(:value),
      average_time_to_convert: average(:time_to_convert)
    }
  end

  def self.by_event_breakdown
    group(:event_name).count
  end

  # Instance methods
  def formatted_time_to_convert
    return "N/A" if time_to_convert.nil?

    seconds = time_to_convert
    days = seconds / 86400
    hours = (seconds % 86400) / 3600
    minutes = (seconds % 3600) / 60

    if days > 0
      "#{days}d #{hours}h"
    elsif hours > 0
      "#{hours}h #{minutes}m"
    else
      "#{minutes}m"
    end
  end

  def formatted_value
    return "N/A" if value.nil?

    "$#{value.round(2)}"
  end

  private

  def calculate_time_to_convert
    self.time_to_convert ||= (Time.current - lead.created_at).to_i if lead.present?
  end
end
