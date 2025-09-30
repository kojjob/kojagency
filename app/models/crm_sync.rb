class CrmSync < ApplicationRecord
  # Associations
  belongs_to :lead

  # Enums
  enum :sync_status, {
    pending: 'pending',
    syncing: 'syncing',
    synced: 'synced',
    failed: 'failed'
  }, suffix: true

  # Validations
  validates :crm_system, presence: true
  validates :crm_system, inclusion: {
    in: %w[hubspot salesforce],
    message: "%{value} is not a valid CRM system"
  }
  validates :crm_system, uniqueness: { scope: :lead_id }

  # Scopes
  scope :by_crm_system, ->(system) { where(crm_system: system) }
  scope :pending_syncs, -> { where(sync_status: 'pending') }
  scope :failed_syncs, -> { where(sync_status: 'failed') }
  scope :synced_records, -> { where(sync_status: 'synced') }
  scope :recent_syncs, -> { where('last_synced_at >= ?', 24.hours.ago) }

  # Callbacks
  after_update :track_sync_time, if: :saved_change_to_sync_status?

  # Class methods
  def self.sync_statistics
    {
      total_syncs: count,
      pending: pending_syncs.count,
      synced: synced_records.count,
      failed: failed_syncs.count,
      hubspot_syncs: by_crm_system('hubspot').count,
      salesforce_syncs: by_crm_system('salesforce').count,
      recent_sync_rate: recent_syncs.count
    }
  end

  def self.needs_retry
    failed_syncs.where('updated_at < ?', 1.hour.ago)
  end

  # Instance methods
  def mark_as_synced!(crm_id)
    update!(
      sync_status: 'synced',
      crm_id: crm_id,
      sync_error: nil,
      last_synced_at: Time.current
    )
  end

  def mark_as_failed!(error_message)
    update!(
      sync_status: 'failed',
      sync_error: error_message,
      metadata: metadata.merge(
        failed_at: Time.current,
        retry_count: (metadata['retry_count'] || 0) + 1
      )
    )
  end

  def retry_sync!
    return false if synced?

    update!(
      sync_status: 'pending',
      sync_error: nil,
      metadata: metadata.merge(retry_requested_at: Time.current)
    )
  end

  def sync_age
    return nil if last_synced_at.nil?
    Time.current - last_synced_at
  end

  def needs_resync?
    return true if pending? || failed?
    return true if last_synced_at.nil?
    sync_age > 24.hours
  end

  def retry_count
    metadata['retry_count'] || 0
  end

  def can_retry?
    failed? && retry_count < 3
  end

  private

  def track_sync_time
    self.last_synced_at = Time.current if synced?
  end
end
