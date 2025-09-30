class Admin::AnalyticsController < Admin::BaseController
  before_action :set_date_range

  def index
    @service = AnalyticsService.new(date_range: @date_range)

    # Core metrics for dashboard cards
    @funnel_data = @service.lead_conversion_funnel
    @scoring_data = @service.scoring_distribution
    @analytics_funnel = @service.analytics_funnel

    # Chart data
    @daily_metrics = @service.daily_metrics
    @source_attribution = @service.source_attribution
    @campaign_performance = @service.campaign_performance

    # Performance metrics
    @time_to_conversion = @service.time_to_conversion
    @roi_by_channel = @service.roi_by_channel

    # Summary statistics
    @total_leads = Lead.where(created_at: @date_range).count
    @total_conversions = ConversionEvent.where(created_at: @date_range).count
    @average_score = Lead.where(created_at: @date_range).average(:score)&.round(2) || 0
    @total_value = ConversionEvent.where(created_at: @date_range).sum(:value)&.round(2) || 0
  end

  def funnel
    @service = AnalyticsService.new(date_range: @date_range)
    @funnel_data = @service.lead_conversion_funnel
    @analytics_funnel = @service.analytics_funnel

    respond_to do |format|
      format.html
      format.json { render json: { lead_funnel: @funnel_data, analytics_funnel: @analytics_funnel } }
    end
  end

  def sources
    @service = AnalyticsService.new(date_range: @date_range)
    @source_attribution = @service.source_attribution

    respond_to do |format|
      format.html
      format.json { render json: @source_attribution }
    end
  end

  def campaigns
    @service = AnalyticsService.new(date_range: @date_range)
    @campaign_performance = @service.campaign_performance

    respond_to do |format|
      format.html
      format.json { render json: @campaign_performance }
    end
  end

  def conversion_time
    @service = AnalyticsService.new(date_range: @date_range)
    @time_to_conversion = @service.time_to_conversion

    respond_to do |format|
      format.html
      format.json { render json: @time_to_conversion }
    end
  end

  def roi
    @service = AnalyticsService.new(date_range: @date_range)
    @roi_by_channel = @service.roi_by_channel

    respond_to do |format|
      format.html
      format.json { render json: @roi_by_channel }
    end
  end

  private

  def set_date_range
    if params[:start_date].present? && params[:end_date].present?
      @date_range = [
        Date.parse(params[:start_date]).beginning_of_day,
        Date.parse(params[:end_date]).end_of_day
      ]
    elsif params[:period].present?
      @date_range = case params[:period]
                   when 'today'
                     [Time.current.beginning_of_day, Time.current.end_of_day]
                   when 'week'
                     [1.week.ago, Time.current]
                   when 'month'
                     [1.month.ago, Time.current]
                   when 'quarter'
                     [3.months.ago, Time.current]
                   when 'year'
                     [1.year.ago, Time.current]
                   else
                     [30.days.ago, Time.current]
                   end
    else
      @date_range = [30.days.ago, Time.current]
    end

    @period_label = params[:period] || 'Last 30 Days'
  end
end