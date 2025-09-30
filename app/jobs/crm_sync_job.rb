class CrmSyncJob < ApplicationJob
  queue_as :default

  retry_on StandardError, wait: :exponentially_longer, attempts: 3

  def perform(crm_sync_id)
    @crm_sync = CrmSync.find(crm_sync_id)
    @lead = @crm_sync.lead

    case @crm_sync.crm_system
    when "hubspot"
      sync_to_hubspot
    when "salesforce"
      sync_to_salesforce
    else
      Rails.logger.error("Unknown CRM system: #{@crm_sync.crm_system}")
    end
  rescue ActiveRecord::RecordNotFound => e
    Rails.logger.error("CrmSyncJob: CRM sync #{crm_sync_id} not found: #{e.message}")
  rescue StandardError => e
    Rails.logger.error("CrmSyncJob failed for #{crm_sync_id}: #{e.message}")
    @crm_sync.mark_as_failed!(e.message) if @crm_sync
    raise # Re-raise to trigger retry
  end

  private

  def sync_to_hubspot
    service = CRM::HubspotService.new(@lead)

    # Sync contact
    contact_result = service.sync_contact

    if contact_result[:success]
      Rails.logger.info("Successfully synced lead #{@lead.id} to HubSpot: #{contact_result[:data][:contact_id]}")

      # Sync deal if lead is qualified or further along
      if [ "qualified", "proposal_sent", "negotiating", "won" ].include?(@lead.lead_status)
        deal_result = service.sync_deal

        if deal_result[:success]
          Rails.logger.info("Successfully created/updated HubSpot deal: #{deal_result[:data][:deal_id]}")

          # Update deal stage based on lead status
          stage_result = service.update_deal_stage
          Rails.logger.info("Updated HubSpot deal stage: #{stage_result[:data][:stage]}") if stage_result[:success]
        else
          Rails.logger.warn("HubSpot deal sync failed: #{deal_result[:error]}")
        end
      end

      # Add activity note
      note_content = generate_activity_note
      service.add_note(note_content)
    else
      Rails.logger.error("HubSpot contact sync failed: #{contact_result[:error]}")
    end
  end

  def sync_to_salesforce
    service = CRM::SalesforceService.new(@lead)

    # Sync contact
    contact_result = service.sync_contact

    if contact_result[:success]
      Rails.logger.info("Successfully synced lead #{@lead.id} to Salesforce: #{contact_result[:data][:contact_id]}")

      # Sync opportunity if lead is qualified or further along
      if [ "qualified", "proposal_sent", "negotiating", "won" ].include?(@lead.lead_status)
        opportunity_result = service.sync_opportunity

        if opportunity_result[:success]
          Rails.logger.info("Successfully created/updated Salesforce opportunity: #{opportunity_result[:data][:opportunity_id]}")

          # Update opportunity stage based on lead status
          stage_result = service.update_opportunity_stage
          Rails.logger.info("Updated Salesforce opportunity stage: #{stage_result[:data][:stage]}") if stage_result[:success]
        else
          Rails.logger.warn("Salesforce opportunity sync failed: #{opportunity_result[:error]}")
        end
      end

      # Create task for follow-up
      task_subject = "Follow up: #{@lead.full_name} - #{@lead.project_type_display}"
      task_description = generate_activity_note
      service.create_task(task_subject, task_description)
    else
      Rails.logger.error("Salesforce contact sync failed: #{contact_result[:error]}")
    end
  end

  def generate_activity_note
    <<~NOTE
      Lead: #{@lead.full_name}
      Email: #{@lead.email}
      Company: #{@lead.company}
      Project Type: #{@lead.project_type_display}
      Budget: #{@lead.budget_range_display}
      Timeline: #{@lead.timeline_display}
      Priority: #{@lead.priority_level.upcase} (Score: #{@lead.score})

      Project Description:
      #{@lead.project_description}

      Source: #{@lead.source}
      Created: #{@lead.created_at.strftime('%B %d, %Y at %I:%M %p')}
      #{'Contacted: ' + @lead.contacted_at.strftime('%B %d, %Y at %I:%M %p') if @lead.contacted_at.present?}
    NOTE
  end
end
