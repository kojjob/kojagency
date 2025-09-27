require 'csv'

module Admin
  class LeadsController < ApplicationController
    before_action :authenticate_admin!
    before_action :require_admin
    before_action :set_lead, only: [:show, :update, :destroy, :contact, :qualify, :disqualify, :archive]

    def index
      @leads = Lead.includes(:lead_status)

      # Filter by priority
      case params[:priority]
      when 'high'
        @leads = @leads.high_priority
      when 'medium'
        @leads = @leads.medium_priority
      when 'low'
        @leads = @leads.low_priority
      end

      # Filter by status
      @leads = @leads.where(lead_status: params[:status]) if params[:status].present?

      # Filter by project type
      @leads = @leads.where(project_type: params[:project_type]) if params[:project_type].present?

      # Search functionality
      if params[:q].present?
        @leads = @leads.where(
          'first_name ILIKE :q OR last_name ILIKE :q OR email ILIKE :q OR company ILIKE :q OR project_description ILIKE :q',
          q: "%#{params[:q]}%"
        )
      end

      # Filter by date range
      if params[:start_date].present? && params[:end_date].present?
        @leads = @leads.where(created_at: Date.parse(params[:start_date])..Date.parse(params[:end_date]))
      end

      # Sort options
      case params[:sort]
      when 'score_desc'
        @leads = @leads.order(score: :desc)
      when 'score_asc'
        @leads = @leads.order(score: :asc)
      when 'name'
        @leads = @leads.order(:first_name, :last_name)
      when 'created_desc'
        @leads = @leads.order(created_at: :desc)
      when 'created_asc'
        @leads = @leads.order(created_at: :asc)
      else
        @leads = @leads.order(created_at: :desc)
      end

      @leads = @leads.page(params[:page]).per(25)

      # Statistics for dashboard
      @stats = {
        total: Lead.count,
        high_priority: Lead.high_priority.count,
        medium_priority: Lead.medium_priority.count,
        low_priority: Lead.low_priority.count,
        pending: Lead.pending.count,
        contacted: Lead.contacted.count,
        qualified: Lead.qualified.count,
        this_week: Lead.where(created_at: 1.week.ago..Time.current).count,
        this_month: Lead.where(created_at: 1.month.ago..Time.current).count
      }
    end

    def show
      @notes = @lead.notes || ""
    end

    def update
      if @lead.update(lead_params)
        redirect_to admin_lead_path(@lead), notice: 'Lead was successfully updated.'
      else
        render :show, status: :unprocessable_entity
      end
    end

    def destroy
      @lead.destroy
      redirect_to admin_leads_path, notice: 'Lead was successfully deleted.'
    end

    def contact
      @lead.mark_as_contacted!
      redirect_to admin_lead_path(@lead), notice: 'Lead marked as contacted.'
    end

    def qualify
      @lead.mark_as_qualified!
      redirect_to admin_lead_path(@lead), notice: 'Lead marked as qualified.'
    end

    def disqualify
      @lead.update!(lead_status: 'unqualified')
      redirect_to admin_lead_path(@lead), notice: 'Lead marked as unqualified.'
    end

    def archive
      @lead.update!(lead_status: 'lost')
      redirect_to admin_leads_path, notice: 'Lead has been archived.'
    end

    def export
      @leads = Lead.all

      # Apply same filters as index
      case params[:priority]
      when 'high'
        @leads = @leads.high_priority
      when 'medium'
        @leads = @leads.medium_priority
      when 'low'
        @leads = @leads.low_priority
      end

      @leads = @leads.where(lead_status: params[:status]) if params[:status].present?
      @leads = @leads.where(project_type: params[:project_type]) if params[:project_type].present?

      if params[:q].present?
        @leads = @leads.where(
          'first_name ILIKE :q OR last_name ILIKE :q OR email ILIKE :q OR company ILIKE :q',
          q: "%#{params[:q]}%"
        )
      end

      respond_to do |format|
        format.csv do
          headers['Content-Disposition'] = "attachment; filename=\"leads-#{Date.current}.csv\""
          headers['Content-Type'] = 'text/csv'
          render plain: generate_csv(@leads)
        end
      end
    end

    private

    def set_lead
      @lead = Lead.find(params[:id])
    end

    def lead_params
      params.require(:lead).permit(:notes, :assigned_to, :lead_status)
    end

    def generate_csv(leads)
      CSV.generate(headers: true) do |csv|
        csv << [
          'ID', 'Name', 'Email', 'Phone', 'Company', 'Website',
          'Project Type', 'Budget', 'Timeline', 'Priority', 'Score',
          'Status', 'Created At', 'Contacted At', 'Qualified At',
          'Assigned To', 'Notes'
        ]

        leads.each do |lead|
          csv << [
            lead.id,
            lead.full_name,
            lead.email,
            lead.phone,
            lead.company,
            lead.website,
            lead.project_type_display,
            lead.budget_range_display,
            lead.timeline_display,
            lead.priority_level,
            lead.score,
            lead.lead_status.humanize,
            lead.created_at.strftime('%Y-%m-%d %H:%M'),
            lead.contacted_at&.strftime('%Y-%m-%d %H:%M'),
            lead.qualified_at&.strftime('%Y-%m-%d %H:%M'),
            lead.assigned_to,
            lead.notes
          ]
        end
      end
    end
  end
end