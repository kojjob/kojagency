class EmailSequence < ApplicationRecord
  # Associations
  belongs_to :lead

  # Enums
  enum :status, {
    active: 'active',
    paused: 'paused',
    completed: 'completed',
    cancelled: 'cancelled'
  }, suffix: true

  # Validations
  validates :sequence_name, presence: true
  validates :sequence_name, inclusion: {
    in: %w[welcome nurture qualification proposal follow_up reengagement],
    message: "%{value} is not a valid sequence name"
  }
  validates :current_step, numericality: { greater_than_or_equal_to: 0 }
  validates :sequence_name, uniqueness: { scope: :lead_id }

  # Scopes
  scope :active_sequences, -> { where(status: 'active') }
  scope :paused_sequences, -> { where(status: 'paused') }
  scope :completed_sequences, -> { where(status: 'completed') }
  scope :by_sequence, ->(name) { where(sequence_name: name) }
  scope :pending_next_step, -> { active_sequences.where('current_step < ?', max_steps_for_sequence) }

  # Callbacks
  before_create :set_started_at
  after_update :set_completed_at, if: :completed?

  # Class methods
  def self.sequence_names
    %w[welcome nurture qualification proposal follow_up reengagement]
  end

  def self.create_for_lead(lead, sequence_name)
    create!(
      lead: lead,
      sequence_name: sequence_name,
      current_step: 0,
      status: 'active',
      metadata: {
        lead_score: lead.score,
        lead_priority: lead.priority_level,
        started_by: 'system'
      }
    )
  end

  # Instance methods
  def advance_step!
    return false if completed? || cancelled?

    new_step = current_step + 1
    max_steps = self.class.max_steps_for(sequence_name)

    if new_step >= max_steps
      update!(
        current_step: new_step,
        status: 'completed',
        completed_at: Time.current
      )
    else
      update!(current_step: new_step)
    end
  end

  def pause!
    update!(status: 'paused', metadata: metadata.merge(paused_at: Time.current))
  end

  def resume!
    return false unless paused?
    update!(status: 'active', metadata: metadata.merge(resumed_at: Time.current))
  end

  def cancel!
    update!(status: 'cancelled', metadata: metadata.merge(cancelled_at: Time.current))
  end

  def completed?
    status == 'completed'
  end

  def progress_percentage
    return 100 if completed?
    max_steps = self.class.max_steps_for(sequence_name)
    return 0 if max_steps.zero?

    ((current_step.to_f / max_steps) * 100).round(2)
  end

  def next_email_date
    return nil if completed? || cancelled?

    days_between = case sequence_name
                   when 'welcome' then 1 # Daily for first week
                   when 'nurture' then 3 # Every 3 days
                   when 'qualification' then 2 # Every 2 days
                   when 'proposal' then 1 # Daily follow-up
                   when 'follow_up' then 7 # Weekly
                   when 'reengagement' then 14 # Bi-weekly
                   else 7
                   end

    (started_at || created_at) + (current_step * days_between).days
  end

  def self.max_steps_for(sequence_name)
    case sequence_name
    when 'welcome' then 5 # 5 day welcome series
    when 'nurture' then 10 # 30 day nurture campaign
    when 'qualification' then 6 # 12 day qualification
    when 'proposal' then 7 # 7 day proposal follow-up
    when 'follow_up' then 4 # 4 week follow-up
    when 'reengagement' then 3 # 6 week reengagement
    else 5
    end
  end

  private

  def max_steps_for_sequence
    self.class.max_steps_for(sequence_name)
  end

  def set_started_at
    self.started_at ||= Time.current
  end

  def set_completed_at
    self.completed_at = Time.current if completed? && completed_at.nil?
  end
end
