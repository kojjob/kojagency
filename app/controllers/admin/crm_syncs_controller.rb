class Admin::CrmSyncsController < Admin::BaseController
  before_action :set_crm_sync, only: [ :show, :retry ]

  def index
    @crm_syncs = CrmSync.includes(:lead)
                        .order(updated_at: :desc)
                        .page(params[:page])
                        .per(20)

    # Filter by CRM system if specified
    @crm_syncs = @crm_syncs.by_crm_system(params[:crm_system]) if params[:crm_system].present?

    # Filter by status if specified
    case params[:status]
    when "pending"
      @crm_syncs = @crm_syncs.pending_syncs
    when "synced"
      @crm_syncs = @crm_syncs.synced_records
    when "failed"
      @crm_syncs = @crm_syncs.failed_syncs
    end

    @sync_stats = CrmSync.sync_statistics
  end

  def show
    @activity_log = @crm_sync.metadata.dig("activity_log") || []
    @sync_history = @crm_sync.metadata.dig("sync_history") || []
  end

  def retry
    if @crm_sync.can_retry?
      @crm_sync.retry_sync!
      CrmSyncJob.perform_later(@crm_sync.id)

      redirect_to admin_crm_syncs_path, notice: "CRM sync retry has been queued."
    else
      redirect_to admin_crm_syncs_path, alert: "This sync cannot be retried (max attempts reached or already synced)."
    end
  end

  def retry_failed
    failed_syncs = CrmSync.needs_retry

    if failed_syncs.any?
      failed_syncs.each do |sync|
        sync.retry_sync!
        CrmSyncJob.perform_later(sync.id)
      end

      redirect_to admin_crm_syncs_path, notice: "#{failed_syncs.count} failed syncs have been queued for retry."
    else
      redirect_to admin_crm_syncs_path, notice: "No failed syncs found that need retry."
    end
  end

  def sync_all_pending
    pending_syncs = CrmSync.pending_syncs

    if pending_syncs.any?
      pending_syncs.each do |sync|
        CrmSyncJob.perform_later(sync.id)
      end

      redirect_to admin_crm_syncs_path, notice: "#{pending_syncs.count} pending syncs have been queued."
    else
      redirect_to admin_crm_syncs_path, notice: "No pending syncs found."
    end
  end

  def dashboard
    @sync_stats = CrmSync.sync_statistics

    # Recent sync activity
    @recent_syncs = CrmSync.includes(:lead)
                           .order(last_synced_at: :desc)
                           .limit(10)

    # Failed syncs requiring attention
    @failed_syncs = CrmSync.failed_syncs
                           .includes(:lead)
                           .order(updated_at: :desc)
                           .limit(10)

    # Pending syncs
    @pending_syncs = CrmSync.pending_syncs
                            .includes(:lead)
                            .order(created_at: :asc)
                            .limit(10)

    # Sync performance by CRM system
    @hubspot_stats = {
      total: CrmSync.by_crm_system("hubspot").count,
      synced: CrmSync.by_crm_system("hubspot").synced_records.count,
      failed: CrmSync.by_crm_system("hubspot").failed_syncs.count,
      pending: CrmSync.by_crm_system("hubspot").pending_syncs.count
    }

    @salesforce_stats = {
      total: CrmSync.by_crm_system("salesforce").count,
      synced: CrmSync.by_crm_system("salesforce").synced_records.count,
      failed: CrmSync.by_crm_system("salesforce").failed_syncs.count,
      pending: CrmSync.by_crm_system("salesforce").pending_syncs.count
    }

    # Sync rate trends (last 7 days)
    @sync_trends = (0..6).map do |days_ago|
      date = days_ago.days.ago.to_date
      {
        date: date.strftime("%b %d"),
        synced: CrmSync.synced_records.where("DATE(last_synced_at) = ?", date).count,
        failed: CrmSync.failed_syncs.where("DATE(updated_at) = ?", date).count
      }
    end.reverse
  end

  private

  def set_crm_sync
    @crm_sync = CrmSync.find(params[:id])
  end
end
