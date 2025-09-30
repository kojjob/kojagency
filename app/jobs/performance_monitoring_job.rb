class PerformanceMonitoringJob < ApplicationJob
  queue_as :default

  # Run daily to collect performance metrics and system health data
  def perform
    collect_lead_metrics
    collect_conversion_metrics
    collect_system_health
    check_response_time_sla
    generate_daily_report
  end

  private

  def collect_lead_metrics
    today = Time.current.beginning_of_day..Time.current.end_of_day

    metrics = {
      date: Date.current,
      total_leads: Lead.where(created_at: today).count,
      high_priority_leads: Lead.where(created_at: today).high_priority.count,
      contacted_leads: Lead.where(contacted_at: today).count,
      overdue_responses: Lead.uncontacted.select(&:overdue_response?).count,
      average_score: Lead.where(created_at: today).average(:score)&.round(2) || 0
    }

    Rails.logger.info "[PerformanceMonitoring] Daily Lead Metrics: #{metrics}"

    # Store in analytics for historical tracking
    Lead.where(created_at: today).find_each do |lead|
      Analytic.create!(
        lead: lead,
        event_type: 'contact',
        source: lead.source,
        metadata: {
          score: lead.score,
          priority: lead.priority_level,
          status: lead.lead_status
        }
      )
    end
  end

  def collect_conversion_metrics
    today = Time.current.beginning_of_day..Time.current.end_of_day

    metrics = {
      date: Date.current,
      total_conversions: ConversionEvent.where(created_at: today).count,
      conversions_by_event: ConversionEvent.where(created_at: today).by_event_breakdown,
      total_value: ConversionEvent.where(created_at: today).sum(:value),
      average_time_to_convert: ConversionEvent.where(created_at: today)
                                             .where.not(time_to_convert: nil)
                                             .average(:time_to_convert)
    }

    Rails.logger.info "[PerformanceMonitoring] Daily Conversion Metrics: #{metrics}"
  end

  def collect_system_health
    health_data = {
      date: Date.current,
      database_connection: check_database_connection,
      active_storage: check_active_storage,
      background_jobs: check_background_jobs,
      memory_usage: check_memory_usage,
      disk_space: check_disk_space
    }

    Rails.logger.info "[PerformanceMonitoring] System Health: #{health_data}"

    # Alert if any critical systems are down
    critical_failures = health_data.select { |k, v| v == false && k != :date }
    if critical_failures.any?
      Rails.logger.error "[PerformanceMonitoring] Critical system failures detected: #{critical_failures.keys}"
      # In production, this would send alerts to admin team
    end
  end

  def check_response_time_sla
    # Check leads that are overdue for response based on priority
    high_priority_overdue = Lead.high_priority.uncontacted.select { |l| l.days_since_creation > 0.04 }.count
    medium_priority_overdue = Lead.medium_priority.uncontacted.select { |l| l.days_since_creation > 0.08 }.count
    low_priority_overdue = Lead.low_priority.uncontacted.select { |l| l.days_since_creation > 1 }.count

    sla_data = {
      date: Date.current,
      high_priority_overdue: high_priority_overdue,
      medium_priority_overdue: medium_priority_overdue,
      low_priority_overdue: low_priority_overdue,
      total_overdue: high_priority_overdue + medium_priority_overdue + low_priority_overdue
    }

    Rails.logger.info "[PerformanceMonitoring] Response Time SLA: #{sla_data}"

    # Alert if SLA violations exceed threshold
    if sla_data[:high_priority_overdue] > 0
      Rails.logger.warn "[PerformanceMonitoring] High priority leads overdue: #{high_priority_overdue}"
      # In production, send urgent alert to sales team
    end

    sla_data
  end

  def generate_daily_report
    service = AnalyticsService.new(date_range: [1.day.ago, Time.current])

    report = {
      date: Date.current,
      funnel_metrics: service.lead_conversion_funnel,
      source_performance: service.source_attribution.first(5),
      scoring_distribution: service.scoring_distribution,
      daily_summary: {
        leads_today: Lead.where(created_at: Time.current.beginning_of_day..Time.current.end_of_day).count,
        conversions_today: ConversionEvent.where(created_at: Time.current.beginning_of_day..Time.current.end_of_day).count,
        revenue_today: ConversionEvent.where(created_at: Time.current.beginning_of_day..Time.current.end_of_day).sum(:value)
      }
    }

    Rails.logger.info "[PerformanceMonitoring] Daily Report Generated: #{report}"

    report
  end

  def check_database_connection
    ActiveRecord::Base.connection.execute('SELECT 1').present?
  rescue => e
    Rails.logger.error "[PerformanceMonitoring] Database connection failed: #{e.message}"
    false
  end

  def check_active_storage
    ActiveStorage::Attachment.count
    true
  rescue => e
    Rails.logger.error "[PerformanceMonitoring] Active Storage check failed: #{e.message}"
    false
  end

  def check_background_jobs
    # Check if Solid Queue is processing jobs
    true # Placeholder - in production would check queue health
  rescue => e
    Rails.logger.error "[PerformanceMonitoring] Background jobs check failed: #{e.message}"
    false
  end

  def check_memory_usage
    # Basic memory check - in production would use system monitoring tools
    process_memory = `ps -o rss= -p #{Process.pid}`.to_i / 1024 # MB
    Rails.logger.info "[PerformanceMonitoring] Memory Usage: #{process_memory}MB"
    process_memory < 1000 # Alert if over 1GB
  rescue => e
    Rails.logger.error "[PerformanceMonitoring] Memory usage check failed: #{e.message}"
    true # Don't fail on monitoring errors
  end

  def check_disk_space
    # Basic disk check - in production would use system monitoring tools
    df_output = `df -h / | tail -1`.split
    usage_percent = df_output[4].to_i
    Rails.logger.info "[PerformanceMonitoring] Disk Usage: #{usage_percent}%"
    usage_percent < 90 # Alert if over 90% full
  rescue => e
    Rails.logger.error "[PerformanceMonitoring] Disk space check failed: #{e.message}"
    true # Don't fail on monitoring errors
  end
end
