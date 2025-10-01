module CRM
  class SalesforceService
    SALESFORCE_API_VERSION = "v59.0"

    def initialize(lead)
      @lead = lead
      @instance_url = Rails.application.credentials.dig(:salesforce, :instance_url)
      @access_token = Rails.application.credentials.dig(:salesforce, :access_token)
      @crm_sync = find_or_create_sync
    end

    def sync_contact
      return failure("Salesforce credentials not configured") if credentials_missing?

      @crm_sync.update!(sync_status: "syncing")

      begin
        response = create_or_update_contact

        if response.success?
          contact_id = extract_record_id(response)
          @crm_sync.mark_as_synced!(contact_id)
          success(contact_id: contact_id)
        else
          error_message = extract_error_message(response)
          @crm_sync.mark_as_failed!(error_message)
          failure(error_message)
        end
      rescue StandardError => e
        @crm_sync.mark_as_failed!(e.message)
        failure(e.message)
      end
    end

    def sync_opportunity
      return failure("Contact not synced") if @crm_sync.crm_id.blank?

      begin
        response = create_or_update_opportunity

        if response.success?
          opportunity_id = extract_record_id(response)
          update_sync_metadata(opportunity_id: opportunity_id)
          success(opportunity_id: opportunity_id)
        else
          failure(extract_error_message(response))
        end
      rescue StandardError => e
        failure(e.message)
      end
    end

    def update_opportunity_stage
      return failure("Opportunity not synced") if opportunity_id.blank?

      stage = map_lead_status_to_stage

      begin
        response = update_opportunity_properties(
          StageName: stage,
          Probability: stage_probability(stage)
        )

        if response.success?
          update_sync_metadata(last_stage_update: Time.current, current_stage: stage)
          success(stage: stage)
        else
          failure(extract_error_message(response))
        end
      rescue StandardError => e
        failure(e.message)
      end
    end

    def create_task(subject, description)
      return failure("Contact not synced") if @crm_sync.crm_id.blank?

      begin
        response = create_salesforce_task(subject, description)

        if response.success?
          task_id = extract_record_id(response)
          success(task_id: task_id)
        else
          failure(extract_error_message(response))
        end
      rescue StandardError => e
        failure(e.message)
      end
    end

    def fetch_contact_history
      return failure("Contact not synced") if @crm_sync.crm_id.blank?

      begin
        response = query_contact_history

        if response.success?
          history = parse_history(response)
          success(history: history)
        else
          failure(extract_error_message(response))
        end
      rescue StandardError => e
        failure(e.message)
      end
    end

    private

    def credentials_missing?
      @instance_url.blank? || @access_token.blank?
    end

    def find_or_create_sync
      @lead.crm_syncs.find_or_create_by!(crm_system: "salesforce")
    end

    def create_or_update_contact
      contact_data = build_contact_data

      if @crm_sync.crm_id.present?
        update_contact(contact_data)
      else
        create_contact(contact_data)
      end
    end

    def build_contact_data
      {
        FirstName: @lead.first_name,
        LastName: @lead.last_name,
        Email: @lead.email,
        Phone: @lead.phone,
        Company: @lead.company || "#{@lead.full_name} - Individual",
        Website__c: @lead.website,
        LeadSource: map_lead_source,
        Project_Type__c: @lead.project_type_display,
        Budget_Range__c: @lead.budget_range_display,
        Timeline__c: @lead.timeline_display,
        Lead_Score__c: @lead.score,
        Description: @lead.project_description
      }.compact
    end

    def create_contact(data)
      HTTParty.post(
        "#{@instance_url}/services/data/#{SALESFORCE_API_VERSION}/sobjects/Contact",
        headers: headers,
        body: data.to_json
      )
    end

    def update_contact(data)
      HTTParty.patch(
        "#{@instance_url}/services/data/#{SALESFORCE_API_VERSION}/sobjects/Contact/#{@crm_sync.crm_id}",
        headers: headers,
        body: data.to_json
      )
    end

    def create_or_update_opportunity
      opportunity_data = build_opportunity_data

      if opportunity_id.present?
        update_opportunity_properties(opportunity_data)
      else
        create_opportunity(opportunity_data)
      end
    end

    def build_opportunity_data
      {
        Name: "#{@lead.company || @lead.full_name} - #{@lead.project_type_display}",
        AccountId: account_id,
        ContactId: @crm_sync.crm_id,
        Amount: estimate_opportunity_value,
        StageName: map_lead_status_to_stage,
        CloseDate: estimate_close_date.strftime("%Y-%m-%d"),
        Probability: stage_probability(map_lead_status_to_stage),
        LeadSource: map_lead_source,
        Type: "New Business",
        Project_Type__c: @lead.project_type_display,
        Budget_Range__c: @lead.budget_range_display,
        Timeline__c: @lead.timeline_display,
        Description: @lead.project_description
      }.compact
    end

    def create_opportunity(data)
      HTTParty.post(
        "#{@instance_url}/services/data/#{SALESFORCE_API_VERSION}/sobjects/Opportunity",
        headers: headers,
        body: data.to_json
      )
    end

    def update_opportunity_properties(properties)
      HTTParty.patch(
        "#{@instance_url}/services/data/#{SALESFORCE_API_VERSION}/sobjects/Opportunity/#{opportunity_id}",
        headers: headers,
        body: properties.to_json
      )
    end

    def create_salesforce_task(subject, description)
      task_data = {
        Subject: subject,
        Description: description,
        WhoId: @crm_sync.crm_id,
        Status: "Not Started",
        Priority: priority_level,
        ActivityDate: Time.current.strftime("%Y-%m-%d")
      }

      HTTParty.post(
        "#{@instance_url}/services/data/#{SALESFORCE_API_VERSION}/sobjects/Task",
        headers: headers,
        body: task_data.to_json
      )
    end

    def query_contact_history
      soql = "SELECT Id, Subject, Description, CreatedDate, LastModifiedDate " \
             "FROM Task WHERE WhoId = '#{@crm_sync.crm_id}' " \
             "ORDER BY CreatedDate DESC LIMIT 50"

      HTTParty.get(
        "#{@instance_url}/services/data/#{SALESFORCE_API_VERSION}/query",
        headers: headers,
        query: { q: soql }
      )
    end

    def map_lead_source
      source_mapping = {
        "website" => "Web",
        "referral" => "Referral",
        "linkedin" => "Social Media",
        "google_ads" => "Advertisement",
        "other" => "Other"
      }

      source_mapping[@lead.source] || "Web"
    end

    def map_lead_status_to_stage
      case @lead.lead_status
      when "pending", "contacted"
        "Prospecting"
      when "qualified"
        "Qualification"
      when "proposal_sent"
        "Proposal/Price Quote"
      when "negotiating"
        "Negotiation/Review"
      when "won"
        "Closed Won"
      when "lost", "unqualified"
        "Closed Lost"
      else
        "Prospecting"
      end
    end

    def stage_probability(stage)
      probabilities = {
        "Prospecting" => 10,
        "Qualification" => 25,
        "Proposal/Price Quote" => 50,
        "Negotiation/Review" => 75,
        "Closed Won" => 100,
        "Closed Lost" => 0
      }

      probabilities[stage] || 10
    end

    def estimate_opportunity_value
      case @lead.budget
      when "under_10k"
        5000
      when "10k_25k"
        17500
      when "25k_50k"
        37500
      when "50k_100k"
        75000
      when "100k_250k"
        175000
      when "250k_plus"
        400000
      else
        50000
      end
    end

    def estimate_close_date
      base_date = Time.current

      case @lead.timeline
      when "asap"
        base_date + 1.month
      when "1_month"
        base_date + 1.month
      when "3_months"
        base_date + 3.months
      when "6_months"
        base_date + 6.months
      when "1_year"
        base_date + 1.year
      else
        base_date + 3.months
      end
    end

    def priority_level
      case @lead.priority_level
      when "high"
        "High"
      when "medium"
        "Normal"
      else
        "Low"
      end
    end

    def opportunity_id
      @crm_sync.metadata["opportunity_id"]
    end

    def account_id
      @crm_sync.metadata["account_id"]
    end

    def update_sync_metadata(data)
      @crm_sync.update!(
        metadata: @crm_sync.metadata.merge(data),
        last_synced_at: Time.current
      )
    end

    def extract_record_id(response)
      JSON.parse(response.body)["id"]
    end

    def extract_error_message(response)
      body = JSON.parse(response.body) rescue {}
      errors = body.is_a?(Array) ? body : [ body ]
      errors.map { |e| e["message"] || e["errorCode"] }.join(", ") || "Unknown Salesforce API error"
    end

    def parse_history(response)
      body = JSON.parse(response.body) rescue {}
      body["records"] || []
    end

    def headers
      {
        "Authorization" => "Bearer #{@access_token}",
        "Content-Type" => "application/json"
      }
    end

    def success(data = {})
      { success: true, data: data }
    end

    def failure(message)
      { success: false, error: message }
    end
  end
end
