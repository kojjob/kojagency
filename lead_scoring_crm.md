# app/controllers/leads_controller.rb
class LeadsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create] # For API access
  
  def create
    @lead = Lead.new(lead_params)
    
    # Capture UTM parameters and referrer data
    @lead.utm_params = capture_utm_params
    
    if @lead.save
      # Calculate lead score
      @lead.calculate_score
      
      # Trigger automated workflows
      LeadWorkflowJob.perform_async(@lead.id)
      
      respond_to do |format|
        format.html { redirect_to root_path(anchor: 'contact'), notice: 'Thank you! We\'ll be in touch soon.' }
        format.json { render json: { success: true, lead_id: @lead.id, score: @lead.lead_score } }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_to root_path(anchor: 'contact'), alert: @lead.errors.full_messages.join(', ') }
        format.json { render json: { success: false, errors: @lead.errors.full_messages } }
        format.turbo_stream
      end
    end
  end
  
  private
  
  def lead_params
    params.require(:lead).permit(
      :name, :email, :phone, :company, :project_type, 
      :budget_range, :timeline, :message
    )
  end
  
  def capture_utm_params
    {
      utm_source: params[:utm_source],
      utm_medium: params[:utm_medium], 
      utm_campaign: params[:utm_campaign],
      utm_term: params[:utm_term],
      utm_content: params[:utm_content],
      referrer: request.referrer,
      user_agent: request.user_agent,
      ip_address: request.remote_ip
    }.compact
  end
end

# app/controllers/admin/leads_controller.rb
class Admin::LeadsController < AdminController
  before_action :set_lead, only: [:show, :update, :destroy]
  
  def index
    @leads = Lead.includes(:notes).order(lead_score: :desc, created_at: :desc)
    
    # Filtering
    @leads = @leads.where(status: params[:status]) if params[:status].present?
    @leads = @leads.where(budget_range: params[:budget_range]) if params[:budget_range].present?
    @leads = @leads.where(project_type: params[:project_type]) if params[:project_type].present?
    @leads = @leads.where('lead_score >= ?', params[:min_score]) if params[:min_score].present?
    
    # Search
    if params[:search].present?
      @leads = @leads.where(
        "name ILIKE ? OR email ILIKE ? OR company ILIKE ?",
        "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%"
      )
    end
    
    # Pagination
    @leads = @leads.page(params[:page]).per(25)
    
    # Statistics for dashboard
    @stats = {
      total_leads: Lead.count,
      new_leads: Lead.new_leads.count,
      high_score_leads: Lead.where('lead_score >= 70').count,
      this_month: Lead.this_month.count,
      avg_score: Lead.average(:lead_score)&.round(1) || 0
    }
  end
  
  def show
    @lead_activities = LeadActivity.where(lead: @lead).order(created_at: :desc)
    @similar_leads = Lead.where.not(id: @lead.id)
                         .where(project_type: @lead.project_type)
                         .where(budget_range: @lead.budget_range)
                         .order(lead_score: :desc)
                         .limit(5)
  end
  
  def update
    if @lead.update(lead_update_params)
      
      # Log the status change
      if @lead.status_changed?
        LeadActivity.create!(
          lead: @lead,
          activity_type: 'status_change',
          description: "Status changed from #{@lead.status_was} to #{@lead.status}",
          user_email: current_user&.email || 'system'
        )
      end
      
      # Trigger follow-up workflows based on status
      case @lead.status
      when 'contacted'
        LeadFollowUpJob.perform_in(2.days, @lead.id)
      when 'qualified'
        ProposalReminderJob.perform_in(1.week, @lead.id)
      end
      
      respond_to do |format|
        format.html { redirect_to admin_lead_path(@lead), notice: 'Lead updated successfully.' }
        format.json { render json: { success: true } }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { render :show, status: :unprocessable_entity }
        format.json { render json: { success: false, errors: @lead.errors.full_messages } }
      end
    end
  end
  
  def bulk_update
    lead_ids = params[:lead_ids] || []
    action = params[:bulk_action]
    
    leads = Lead.where(id: lead_ids)
    
    case action
    when 'mark_contacted'
      leads.update_all(status: 'contacted', contacted_at: Time.current)
    when 'mark_qualified'  
      leads.update_all(status: 'qualified', qualified_at: Time.current)
    when 'delete'
      leads.destroy_all
    end
    
    redirect_to admin_leads_path, notice: "#{leads.count} leads updated successfully."
  end
  
  private
  
  def set_lead
    @lead = Lead.find(params[:id])
  end
  
  def lead_update_params
    params.require(:lead).permit(:status, :notes, :contacted_at, :qualified_at)
  end
end

# app/models/lead_activity.rb
class LeadActivity < ApplicationRecord
  belongs_to :lead
  
  validates :activity_type, presence: true, inclusion: { 
    in: %w[created contacted email_opened email_clicked status_change note_added] 
  }
  validates :description, presence: true
  validates :user_email, presence: true
  
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(activity_type: type) }
  
  enum activity_type: {
    created: 0,
    contacted: 1, 
    email_opened: 2,
    email_clicked: 3,
    status_change: 4,
    note_added: 5
  }
end

# app/services/lead_scoring_service.rb
class LeadScoringService
  def initialize(lead)
    @lead = lead
  end
  
  def calculate_score
    score = 0
    
    # Budget scoring (35% weight)
    score += budget_score * 0.35
    
    # Timeline urgency (25% weight)
    score += timeline_score * 0.25
    
    # Project complexity (20% weight)
    score += complexity_score * 0.20
    
    # Lead quality indicators (10% weight)
    score += quality_score * 0.10
    
    # Company information completeness (10% weight)
    score += completeness_score * 0.10
    
    (score * 100).round
  end
  
  private
  
  attr_reader :lead
  
  def budget_score
    case lead.budget_range
    when 'enterprise' then 1.0
    when 'large' then 0.85
    when 'medium' then 0.65  
    when 'small' then 0.35
    else 0.1
    end
  end
  
  def timeline_score
    case lead.timeline
    when 'asap' then 1.0
    when 'month' then 0.85
    when 'quarter' then 0.65
    when 'year' then 0.35
    else 0.1
    end
  end
  
  def complexity_score
    case lead.project_type
    when 'data' then 1.0      # Highest value projects
    when 'web' then 0.85      # Core competency
    when 'mobile' then 0.75   # High value
    when 'consultation' then 0.45  # Lower commitment
    when 'other' then 0.25    # Unknown scope
    else 0.1
    end
  end
  
  def quality_score
    score = 0.0
    
    # Email domain quality
    if lead.email.present?
      domain = lead.email.split('@').last.downcase
      score += 0.3 if !%w[gmail.com yahoo.com hotmail.com outlook.com].include?(domain)
    end
    
    # Message length and detail
    if lead.message.present?
      word_count = lead.message.split.length
      score += 0.4 if word_count > 20  # Detailed messages
      score += 0.2 if word_count > 10  # Some detail
    end
    
    # Phone number provided
    score += 0.3 if lead.phone.present?
    
    [score, 1.0].min
  end
  
  def completeness_score
    fields_present = [
      lead.company.present? ? 1 : 0,
      lead.phone.present? ? 1 : 0,
      lead.message.present? ? 1 : 0
    ].sum
    
    fields_present / 3.0
  end
end

# app/services/crm_integration_service.rb  
class CrmIntegrationService
  def initialize(lead)
    @lead = lead
  end
  
  def sync_to_hubspot
    return unless hubspot_enabled?
    
    hubspot_client = Hubspot::Client.new(access_token: hubspot_token)
    
    properties = {
      email: @lead.email,
      firstname: first_name,
      lastname: last_name,  
      company: @lead.company,
      phone: @lead.phone,
      message: @lead.message,
      project_type: @lead.project_type,
      budget_range: @lead.budget_range,
      timeline: @lead.timeline,
      lead_score: @lead.lead_score,
      lead_source: @lead.utm_params['utm_source'] || 'website'
    }.compact
    
    contact_input = Hubspot::Crm::Contacts::SimplePublicObjectInput.new(properties: properties)
    
    begin
      response = hubspot_client.crm.contacts.basic_api.create(contact_input: contact_input)
      @lead.update!(hubspot_contact_id: response.id)
      
      # Create activity log
      LeadActivity.create!(
        lead: @lead,
        activity_type: 'created',
        description: 'Contact synced to HubSpot',
        user_email: 'system'
      )
      
      return response
    rescue Hubspot::Client::Error => e
      Rails.logger.error "HubSpot sync failed: #{e.message}"
      return false
    end
  end
  
  def sync_to_salesforce
    return unless salesforce_enabled?
    
    # Salesforce integration logic
    # Similar pattern to HubSpot
  end
  
  private
  
  def first_name
    @lead.name.split(' ').first
  end
  
  def last_name
    name_parts = @lead.name.split(' ')
    name_parts.length > 1 ? name_parts.last : ''
  end
  
  def hubspot_enabled?
    hubspot_token.present?
  end
  
  def hubspot_token
    ENV['HUBSPOT_ACCESS_TOKEN']
  end
  
  def salesforce_enabled?
    ENV['SALESFORCE_CLIENT_ID'].present?
  end
end

# app/jobs/lead_workflow_job.rb
class LeadWorkflowJob < ApplicationJob
  def perform(lead_id)
    lead = Lead.find(lead_id)
    
    # Log lead creation
    LeadActivity.create!(
      lead: lead,
      activity_type: 'created',
      description: 'Lead created from website form',
      user_email: 'system'
    )
    
    # Sync to CRM
    CrmIntegrationService.new(lead).sync_to_hubspot
    
    # Send internal notifications
    LeadNotificationMailer.new_lead(lead).deliver_now if lead.lead_score >= 50
    
    # Schedule follow-up based on score
    if lead.lead_score >= 80
      # High priority - immediate notification
      AdminNotificationJob.perform_now(lead.id, 'high_priority_lead')
    elsif lead.lead_score >= 50  
      # Medium priority - follow up in 2 hours
      LeadFollowUpJob.perform_in(2.hours, lead.id)
    else
      # Low priority - follow up next business day
      LeadFollowUpJob.perform_at(next_business_day, lead.id)
    end
  end
  
  private
  
  def next_business_day
    date = 1.day.from_now
    date += 1.day while date.saturday? || date.sunday?
    date.beginning_of_day + 9.hours # 9 AM
  end
end

# app/mailers/lead_notification_mailer.rb
class LeadNotificationMailer < ApplicationMailer
  default from: 'leads@digitalforge.com'
  
  def new_lead(lead)
    @lead = lead
    @score_level = score_level(@lead.lead_score)
    
    mail(
      to: 'team@digitalforge.com',
      subject: "New #{@score_level} Lead: #{@lead.name} (Score: #{@lead.lead_score})"
    )
  end
  
  def lead_follow_up(lead)
    @lead = lead
    
    mail(
      to: 'sales@digitalforge.com',
      subject: "Follow up required: #{@lead.name}"
    )
  end
  
  private
  
  def score_level(score)
    case score
    when 80..100 then 'High Priority'
    when 50..79 then 'Medium Priority'  
    else 'Low Priority'
    end
  end
end

# app/views/admin/leads/index.html.erb
<div class="bg-white">
  <!-- Header -->
  <div class="border-b border-gray-200 px-4 py-5 sm:px-6">
    <div class="flex justify-between items-center">
      <div>
        <h1 class="text-2xl font-bold text-gray-900">Lead Management</h1>
        <p class="mt-1 text-gray-600">Track and manage incoming leads with AI-powered scoring</p>
      </div>
      
      <div class="flex space-x-3">
        <%= link_to 'Export CSV', admin_leads_path(format: :csv), 
            class: "bg-white border border-gray-300 text-gray-700 px-4 py-2 rounded-lg hover:bg-gray-50 transition-colors" %>
        <%= link_to 'Settings', '#', 
            class: "bg-primary-600 text-white px-4 py-2 rounded-lg hover:bg-primary-700 transition-colors" %>
      </div>
    </div>
  </div>
  
  <!-- Stats Dashboard -->
  <div class="grid grid-cols-1 md:grid-cols-5 gap-6 p-6 border-b border-gray-200">
    <div class="text-center">
      <div class="text-3xl font-bold text-primary-600"><%= @stats[:total_leads] %></div>
      <div class="text-sm text-gray-600">Total Leads</div>
    </div>
    
    <div class="text-center">
      <div class="text-3xl font-bold text-yellow-600"><%= @stats[:new_leads] %></div>
      <div class="text-sm text-gray-600">New This Week</div>
    </div>
    
    <div class="text-center">
      <div class="text-3xl font-bold text-secondary-600"><%= @stats[:high_score_leads] %></div>
      <div class="text-sm text-gray-600">High Quality</div>
    </div>
    
    <div class="text-center">
      <div class="text-3xl font-bold text-purple-600"><%= @stats[:this_month] %></div>
      <div class="text-sm text-gray-600">This Month</div>
    </div>
    
    <div class="text-center">
      <div class="text-3xl font-bold text-gray-900"><%= @stats[:avg_score] %></div>
      <div class="text-sm text-gray-600">Avg Score</div>
    </div>
  </div>
  
  <!-- Filters -->
  <div class="bg-gray-50 px-6 py-4">
    <%= form_with url: admin_leads_path, method: :get, local: true, class: "flex flex-wrap gap-4 items-end" do |f| %>
      <div>
        <%= f.label :status, class: "block text-sm font-medium text-gray-700 mb-1" %>
        <%= f.select :status, options_for_select([
          ['All Statuses', ''],
          ['New', 'new'],
          ['Contacted', 'contacted'], 
          ['Qualified', 'qualified'],
          ['Proposal Sent', 'proposal'],
          ['Closed', 'closed']
        ], params[:status]), {}, { class: "border border-gray-300 rounded-lg px-3 py-2" } %>
      </div>
      
      <div>
        <%= f.label :budget_range, class: "block text-sm font-medium text-gray-700 mb-1" %>
        <%= f.select :budget_range, options_for_select([
          ['All Budgets', ''],
          ['$10k - $25k', 'small'],
          ['$25k - $100k', 'medium'],
          ['$100k - $500k', 'large'],
          ['$500k+', 'enterprise']
        ], params[:budget_range]), {}, { class: "border border-gray-300 rounded-lg px-3 py-2" } %>
      </div>
      
      <div>
        <%= f.label :project_type, class: "block text-sm font-medium text-gray-700 mb-1" %>
        <%= f.select :project_type, options_for_select([
          ['All Projects', ''],
          ['Web Development', 'web'],
          ['Mobile App', 'mobile'],
          ['Data Analytics', 'data'],
          ['Consultation', 'consultation']
        ], params[:project_type]), {}, { class: "border border-gray-300 rounded-lg px-3 py-2" } %>
      </div>
      
      <div>
        <%= f.label :search, class: "block text-sm font-medium text-gray-700 mb-1" %>
        <%= f.text_field :search, placeholder: "Search leads...", value: params[:search],
            class: "border border-gray-300 rounded-lg px-3 py-2" %>
      </div>
      
      <%= f.submit "Filter", class: "bg-primary-600 text-white px-4 py-2 rounded-lg hover:bg-primary-700 transition-colors" %>
      <%= link_to "Clear", admin_leads_path, class: "text-gray-600 hover:text-gray-800" %>
    <% end %>
  </div>
  
  <!-- Leads Table -->
  <div class="overflow-x-auto">
    <table class="min-w-full divide-y divide-gray-200">
      <thead class="bg-gray-50">
        <tr>
          <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">
            <input type="checkbox" class="rounded border-gray-300" id="select-all">
          </th>
          <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Lead</th>
          <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Project</th>
          <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Score</th>
          <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Status</th>
          <th class="px-6 py-3 text-left text-xs font-medium text-gray-500 uppercase tracking-wider">Created</th>
          <th class="px-6 py-3 text-right text-xs font-medium text-gray-500 uppercase tracking-wider">Actions</th>
        </tr>
      </thead>
      <tbody class="bg-white divide-y divide-gray-200">
        <% @leads.each do |lead| %>
          <tr class="hover:bg-gray-50" data-controller="lead-row" data-lead-id="<%= lead.id %>">
            <td class="px-6 py-4 whitespace-nowrap">
              <input type="checkbox" class="rounded border-gray-300" value="<%= lead.id %>">
            </td>
            
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="flex items-center">
                <div class="w-10 h-10 bg-primary-100 rounded-full flex items-center justify-center">
                  <span class="text-sm font-medium text-primary-800">
                    <%= lead.name.split(' ').map(&:first).join('').upcase %>
                  </span>
                </div>
                <div class="ml-4">
                  <div class="font-medium text-gray-900"><%= lead.name %></div>
                  <div class="text-sm text-gray-600"><%= lead.email %></div>
                  <% if lead.company.present? %>
                    <div class="text-xs text-gray-500"><%= lead.company %></div>
                  <% end %>
                </div>
              </div>
            </td>
            
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="text-sm text-gray-900"><%= lead.project_type.humanize %></div>
              <div class="text-xs text-gray-600">
                <%= lead.budget_range.humanize %> • <%= lead.timeline.humanize %>
              </div>
            </td>
            
            <td class="px-6 py-4 whitespace-nowrap">
              <div class="flex items-center">
                <div class="flex-1 w-16 bg-gray-200 rounded-full h-2">
                  <div class="h-2 rounded-full <%= score_color(lead.lead_score) %>" 
                       style="width: <%= lead.lead_score %>%"></div>
                </div>
                <span class="ml-2 text-sm font-medium text-gray-900"><%= lead.lead_score %></span>
              </div>
              <div class="text-xs text-gray-600 mt-1"><%= score_label(lead.lead_score) %></div>
            </td>
            
            <td class="px-6 py-4 whitespace-nowrap">
              <span class="px-2 py-1 text-xs font-medium rounded-full <%= status_color(lead.status) %>">
                <%= lead.status.humanize %>
              </span>
            </td>
            
            <td class="px-6 py-4 whitespace-nowrap text-sm text-gray-600">
              <%= time_ago_in_words(lead.created_at) %> ago
            </td>
            
            <td class="px-6 py-4 whitespace-nowrap text-right text-sm font-medium">
              <div class="flex items-center justify-end space-x-2">
                <%= link_to admin_lead_path(lead), 
                    class: "text-primary-600 hover:text-primary-700" do %>
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M2.458 12C3.732 7.943 7.523 5 12 5c4.478 0 8.268 2.943 9.542 7-1.274 4.057-5.064 7-9.542 7-4.477 0-8.268-2.943-9.542-7z"/>
                  </svg>
                <% end %>
                
                <%= link_to "mailto:#{lead.email}", 
                    class: "text-gray-400 hover:text-gray-600" do %>
                  <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 4.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                  </svg>
                <% end %>
              </div>
            </td>
          </tr>
        <% end %>
      </tbody>
    </table>
  </div>
  
  <!-- Pagination -->
  <div class="px-6 py-4 border-t border-gray-200">
    <%= paginate @leads if respond_to?(:paginate) %>
  </div>
</div>

<% content_for :head do %>
  <script>
    // Lead scoring color helpers
    function scoreColor(score) {
      if (score >= 80) return 'bg-green-500';
      if (score >= 60) return 'bg-yellow-500';
      if (score >= 40) return 'bg-orange-500';
      return 'bg-red-500';
    }
    
    function scoreLabel(score) {
      if (score >= 80) return 'High Priority';
      if (score >= 60) return 'Medium Priority';
      if (score >= 40) return 'Low Priority';
      return 'Very Low';
    }
  </script>
<% end %>

# API endpoint for external integrations
# app/controllers/api/v1/leads_controller.rb
class Api::V1::LeadsController < Api::V1::BaseController
  def create
    @lead = Lead.new(lead_params)
    
    if @lead.save
      @lead.calculate_score
      LeadWorkflowJob.perform_async(@lead.id)
      
      render json: {
        success: true,
        lead: {
          id: @lead.id,
          score: @lead.lead_score,
          status: @lead.status
        }
      }, status: :created
    else
      render json: {
        success: false,
        errors: @lead.errors.full_messages
      }, status: :unprocessable_entity
    end
  end
  
  def show
    @lead = Lead.find(params[:id])
    
    render json: {
      lead: {
        id: @lead.id,
        name: @lead.name,
        email: @lead.email,
        company: @lead.company,
        project_type: @lead.project_type,
        budget_range: @lead.budget_range,
        timeline: @lead.timeline,
        status: @lead.status,
        score: @lead.lead_score,
        created_at: @lead.created_at
      }
    }
  end
  
  def update
    @lead = Lead.find(params[:id])
    
    if @lead.update(lead_update_params)
      render json: { success: true, lead: @lead }
    else
      render json: { success: false, errors: @lead.errors.full_messages }
    end
  end
  
  private
  
  def lead_params
    params.require(:lead).permit(
      :name, :email, :phone, :company, :project_type,
      :budget_range, :timeline, :message
    )
  end
  
  def lead_update_params
    params.require(:lead).permit(:status, :notes)
  end
end

# WebHook for external CRM systems
# app/controllers/webhooks/crm_controller.rb
class Webhooks::CrmController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def hubspot
    case params[:subscriptionType]
    when 'contact.propertyChange'
      handle_contact_update(params[:events])
    when 'contact.creation'
      handle_contact_creation(params[:events])
    end
    
    head :ok
  end
  
  private
  
  def handle_contact_update(events)
    events.each do |event|
      lead = Lead.find_by(hubspot_contact_id: event[:objectId])
      next unless lead
      
      # Sync back status changes from HubSpot
      if event[:propertyName] == 'lifecyclestage'
        update_lead_status(lead, event[:propertyValue])
      end
    end
  end
  
  def update_lead_status(lead, hubspot_stage)
    status = case hubspot_stage
    when 'lead' then 'contacted'
    when 'marketingqualifiedlead' then 'qualified' 
    when 'opportunity' then 'proposal'
    when 'customer' then 'closed'
    else lead.status
    end
    
    lead.update!(status: status) if lead.status != status
  end
end