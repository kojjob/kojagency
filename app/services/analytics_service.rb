class AnalyticsService
  def initialize(date_range: nil)
    @start_date = date_range&.first || 30.days.ago
    @end_date = date_range&.last || Time.current
  end

  # Lead conversion funnel analysis
  def lead_conversion_funnel
    base_scope = Lead.where(created_at: @start_date..@end_date)

    {
      total_leads: base_scope.count,
      contacted: base_scope.contacted.count,
      qualified: base_scope.qualified.count,
      proposal_sent: base_scope.proposal_sent.count,
      won: base_scope.won.count,
      conversion_rates: {
        contacted_rate: calculate_rate(base_scope.contacted.count, base_scope.count),
        qualified_rate: calculate_rate(base_scope.qualified.count, base_scope.contacted.count),
        proposal_rate: calculate_rate(base_scope.proposal_sent.count, base_scope.qualified.count),
        won_rate: calculate_rate(base_scope.won.count, base_scope.proposal_sent.count),
        overall_conversion: calculate_rate(base_scope.won.count, base_scope.count)
      }
    }
  end

  # Source attribution analysis
  def source_attribution
    analytics = Analytic.for_date_range(@start_date, @end_date)

    sources = analytics.pluck(:source).compact.uniq

    sources.map do |source|
      source_leads = Lead.where(source: source, created_at: @start_date..@end_date)

      {
        source: source,
        total_leads: source_leads.count,
        high_priority_leads: source_leads.high_priority.count,
        conversion_rate: calculate_rate(source_leads.won.count, source_leads.count),
        average_score: source_leads.average(:score)&.round(2) || 0,
        qualified_leads: source_leads.qualified.count,
        won_deals: source_leads.won.count
      }
    end.sort_by { |s| -s[:total_leads] }
  end

  # Lead scoring distribution over time
  def scoring_distribution
    base_scope = Lead.where(created_at: @start_date..@end_date)

    {
      high_priority: {
        count: base_scope.high_priority.count,
        percentage: calculate_rate(base_scope.high_priority.count, base_scope.count)
      },
      medium_priority: {
        count: base_scope.medium_priority.count,
        percentage: calculate_rate(base_scope.medium_priority.count, base_scope.count)
      },
      low_priority: {
        count: base_scope.low_priority.count,
        percentage: calculate_rate(base_scope.low_priority.count, base_scope.count)
      },
      average_score: base_scope.average(:score)&.round(2) || 0,
      score_trend: calculate_score_trend
    }
  end

  # Time to conversion analysis
  def time_to_conversion
    conversions = ConversionEvent.for_date_range(@start_date, @end_date)
                                  .where.not(time_to_convert: nil)

    {
      average_time_to_contact: average_conversion_time("lead_contacted"),
      average_time_to_qualified: average_conversion_time("lead_qualified"),
      average_time_to_proposal: average_conversion_time("proposal_sent"),
      average_time_to_won: average_conversion_time("deal_won"),
      by_score_tier: {
        high_priority: conversion_time_by_score(80..100),
        medium_priority: conversion_time_by_score(60...80),
        low_priority: conversion_time_by_score(0...60)
      }
    }
  end

  # ROI by marketing channel
  def roi_by_channel
    analytics = Analytic.for_date_range(@start_date, @end_date)

    channels = analytics.pluck(:source).compact.uniq

    channels.map do |channel|
      channel_leads = Lead.where(source: channel, created_at: @start_date..@end_date)
      won_leads = channel_leads.won

      # Calculate total value from conversion events
      total_value = ConversionEvent.joins(:lead)
                                   .where(leads: { source: channel })
                                   .where("conversion_events.created_at >= ? AND conversion_events.created_at <= ?", @start_date, @end_date)
                                   .sum(:value) || 0

      {
        channel: channel,
        total_leads: channel_leads.count,
        won_deals: won_leads.count,
        total_value: total_value.round(2),
        average_deal_value: won_leads.any? ? (total_value / won_leads.count).round(2) : 0,
        conversion_rate: calculate_rate(won_leads.count, channel_leads.count),
        cost_per_lead: 0, # To be integrated with marketing spend data
        roi: calculate_roi(total_value, 0) # Placeholder for cost data
      }
    end.sort_by { |c| -c[:total_value] }
  end

  # Analytics event funnel
  def analytics_funnel
    analytics = Analytic.for_date_range(@start_date, @end_date)

    funnel = analytics.funnel_metrics

    {
      page_views: funnel[:page_views],
      form_starts: funnel[:form_starts],
      form_submits: funnel[:form_submits],
      conversions: funnel[:conversions],
      conversion_rates: {
        form_start_rate: calculate_rate(funnel[:form_starts], funnel[:page_views]),
        form_submit_rate: calculate_rate(funnel[:form_submits], funnel[:form_starts]),
        conversion_rate: calculate_rate(funnel[:conversions], funnel[:form_submits])
      }
    }
  end

  # Campaign performance analysis
  def campaign_performance
    analytics = Analytic.for_date_range(@start_date, @end_date)

    campaigns = analytics.pluck(:campaign).compact.uniq

    campaigns.map do |campaign|
      campaign_analytics = analytics.by_campaign(campaign)
      campaign_leads = Lead.joins(:analytics)
                          .where(analytics: { campaign: campaign })
                          .where(created_at: @start_date..@end_date)
                          .distinct

      {
        campaign: campaign,
        page_views: campaign_analytics.by_event_type("page_view").count,
        form_submits: campaign_analytics.by_event_type("form_submit").count,
        leads_generated: campaign_leads.count,
        qualified_leads: campaign_leads.qualified.count,
        won_deals: campaign_leads.won.count,
        conversion_rate: calculate_rate(campaign_leads.won.count, campaign_leads.count)
      }
    end.sort_by { |c| -c[:leads_generated] }
  end

  # Daily metrics for trending charts
  def daily_metrics
    (@start_date.to_date..@end_date.to_date).map do |date|
      day_start = date.beginning_of_day
      day_end = date.end_of_day

      {
        date: date.strftime("%Y-%m-%d"),
        leads: Lead.where(created_at: day_start..day_end).count,
        page_views: Analytic.where(event_type: "page_view", created_at: day_start..day_end).count,
        conversions: ConversionEvent.where(created_at: day_start..day_end).count,
        average_score: Lead.where(created_at: day_start..day_end).average(:score)&.round(2) || 0
      }
    end
  end

  private

  def calculate_rate(numerator, denominator)
    return 0 if denominator.nil? || denominator.zero?
    ((numerator.to_f / denominator) * 100).round(2)
  end

  def average_conversion_time(event_name)
    avg_seconds = ConversionEvent.where(event_name: event_name)
                                 .for_date_range(@start_date, @end_date)
                                 .average(:time_to_convert)

    return "N/A" if avg_seconds.nil?

    format_time_duration(avg_seconds.to_i)
  end

  def conversion_time_by_score(score_range)
    leads = Lead.where(score: score_range, created_at: @start_date..@end_date)
    conversions = ConversionEvent.where(lead_id: leads.pluck(:id))
                                 .where(event_name: "deal_won")

    avg_seconds = conversions.average(:time_to_convert)
    return "N/A" if avg_seconds.nil?

    format_time_duration(avg_seconds.to_i)
  end

  def format_time_duration(seconds)
    days = seconds / 86400
    hours = (seconds % 86400) / 3600

    if days > 0
      "#{days}d #{hours}h"
    elsif hours > 0
      "#{hours}h"
    else
      "#{seconds / 60}m"
    end
  end

  def calculate_score_trend
    # Calculate week-over-week score trend
    current_week = Lead.where(created_at: 7.days.ago..Time.current).average(:score)&.round(2) || 0
    previous_week = Lead.where(created_at: 14.days.ago..7.days.ago).average(:score)&.round(2) || 0

    return 0 if previous_week.zero?

    ((current_week - previous_week) / previous_week * 100).round(2)
  end

  def calculate_roi(revenue, cost)
    return 0 if cost.zero?
    (((revenue - cost) / cost) * 100).round(2)
  end
end
