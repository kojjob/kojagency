module CRM
  class HubspotService
    HUBSPOT_API_BASE = "https://api.hubapi.com"

    def initialize(lead)
      @lead = lead
      @api_key = Rails.application.credentials.dig(:hubspot, :api_key)
      @crm_sync = find_or_create_sync
    end

    def sync_contact
      return failure("HubSpot API key not configured") if @api_key.blank?

      @crm_sync.update!(sync_status: "syncing")

      begin
        response = create_or_update_contact

        if response.success?
          contact_id = extract_contact_id(response)
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

    def sync_deal
      return failure("Contact not synced") if @crm_sync.crm_id.blank?

      begin
        response = create_or_update_deal

        if response.success?
          deal_id = extract_deal_id(response)
          update_sync_metadata(deal_id: deal_id)
          success(deal_id: deal_id)
        else
          failure(extract_error_message(response))
        end
      rescue StandardError => e
        failure(e.message)
      end
    end

    def update_deal_stage
      return failure("Deal not synced") if deal_id.blank?

      stage = map_lead_status_to_deal_stage

      begin
        response = update_deal_properties(dealstage: stage)

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

    def add_note(note_content)
      return failure("Contact not synced") if @crm_sync.crm_id.blank?

      begin
        response = create_note(note_content)

        if response.success?
          note_id = extract_note_id(response)
          success(note_id: note_id)
        else
          failure(extract_error_message(response))
        end
      rescue StandardError => e
        failure(e.message)
      end
    end

    def fetch_contact_activity
      return failure("Contact not synced") if @crm_sync.crm_id.blank?

      begin
        response = get_contact_activity

        if response.success?
          activities = parse_activities(response)
          success(activities: activities)
        else
          failure(extract_error_message(response))
        end
      rescue StandardError => e
        failure(e.message)
      end
    end

    private

    def find_or_create_sync
      @lead.crm_syncs.find_or_create_by!(crm_system: "hubspot")
    end

    def create_or_update_contact
      properties = build_contact_properties

      if @crm_sync.crm_id.present?
        update_contact(properties)
      else
        create_contact(properties)
      end
    end

    def build_contact_properties
      {
        properties: {
          email: @lead.email,
          firstname: @lead.first_name,
          lastname: @lead.last_name,
          phone: @lead.phone,
          company: @lead.company,
          website: @lead.website,
          lead_source: @lead.source,
          project_type: @lead.project_type_display,
          budget_range: @lead.budget_range_display,
          timeline: @lead.timeline_display,
          lead_score: @lead.score,
          lead_status: @lead.lead_status,
          project_description: @lead.project_description
        }
      }
    end

    def create_contact(properties)
      HTTParty.post(
        "#{HUBSPOT_API_BASE}/crm/v3/objects/contacts",
        headers: headers,
        body: properties.to_json
      )
    end

    def update_contact(properties)
      HTTParty.patch(
        "#{HUBSPOT_API_BASE}/crm/v3/objects/contacts/#{@crm_sync.crm_id}",
        headers: headers,
        body: properties.to_json
      )
    end

    def create_or_update_deal
      properties = build_deal_properties

      if deal_id.present?
        update_deal_properties(properties[:properties])
      else
        create_deal(properties)
      end
    end

    def build_deal_properties
      {
        properties: {
          dealname: "#{@lead.company || @lead.full_name} - #{@lead.project_type_display}",
          amount: estimate_deal_value,
          dealstage: map_lead_status_to_deal_stage,
          pipeline: "default",
          closedate: estimate_close_date.to_i * 1000, # HubSpot uses milliseconds
          lead_source: @lead.source,
          project_type: @lead.project_type_display
        },
        associations: [
          {
            to: { id: @crm_sync.crm_id },
            types: [ { associationCategory: "HUBSPOT_DEFINED", associationTypeId: 3 } ] # Contact to Deal
          }
        ]
      }
    end

    def create_deal(properties)
      HTTParty.post(
        "#{HUBSPOT_API_BASE}/crm/v3/objects/deals",
        headers: headers,
        body: properties.to_json
      )
    end

    def update_deal_properties(properties)
      HTTParty.patch(
        "#{HUBSPOT_API_BASE}/crm/v3/objects/deals/#{deal_id}",
        headers: headers,
        body: { properties: properties }.to_json
      )
    end

    def create_note(content)
      note_data = {
        properties: {
          hs_timestamp: Time.current.to_i * 1000,
          hs_note_body: content
        },
        associations: [
          {
            to: { id: @crm_sync.crm_id },
            types: [ { associationCategory: "HUBSPOT_DEFINED", associationTypeId: 10 } ] # Note to Contact
          }
        ]
      }

      HTTParty.post(
        "#{HUBSPOT_API_BASE}/crm/v3/objects/notes",
        headers: headers,
        body: note_data.to_json
      )
    end

    def get_contact_activity
      HTTParty.get(
        "#{HUBSPOT_API_BASE}/crm/v3/objects/contacts/#{@crm_sync.crm_id}/associations/notes",
        headers: headers
      )
    end

    def map_lead_status_to_deal_stage
      case @lead.lead_status
      when "pending", "contacted"
        "appointmentscheduled" # Initial contact stage
      when "qualified"
        "qualifiedtobuy" # Qualified lead stage
      when "proposal_sent"
        "presentationscheduled" # Proposal stage
      when "negotiating"
        "decisionmakerboughtin" # Negotiation stage
      when "won"
        "closedwon" # Deal won
      when "lost", "unqualified"
        "closedlost" # Deal lost
      else
        "appointmentscheduled" # Default to initial stage
      end
    end

    def estimate_deal_value
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

    def deal_id
      @crm_sync.metadata["deal_id"]
    end

    def update_sync_metadata(data)
      @crm_sync.update!(
        metadata: @crm_sync.metadata.merge(data),
        last_synced_at: Time.current
      )
    end

    def extract_contact_id(response)
      JSON.parse(response.body)["id"]
    end

    def extract_deal_id(response)
      JSON.parse(response.body)["id"]
    end

    def extract_note_id(response)
      JSON.parse(response.body)["id"]
    end

    def extract_error_message(response)
      body = JSON.parse(response.body) rescue {}
      body.dig("message") || body.dig("error") || "Unknown HubSpot API error"
    end

    def parse_activities(response)
      body = JSON.parse(response.body) rescue {}
      body["results"] || []
    end

    def headers
      {
        "Authorization" => "Bearer #{@api_key}",
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
