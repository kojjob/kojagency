class EmailSequenceJob < ApplicationJob
  queue_as :default

  def perform(email_sequence_id)
    @sequence = EmailSequence.find(email_sequence_id)
    return unless @sequence.active?

    @lead = @sequence.lead
    current_step = @sequence.current_step

    # Send appropriate email based on sequence type and step
    case @sequence.sequence_name
    when 'welcome'
      send_welcome_sequence(current_step)
    when 'nurture'
      send_nurture_sequence(current_step)
    when 'qualification'
      send_qualification_sequence(current_step)
    when 'proposal'
      send_proposal_sequence(current_step)
    when 'follow_up'
      send_follow_up_sequence(current_step)
    when 'reengagement'
      send_reengagement_sequence(current_step)
    end

    # Track email analytics
    track_email_sent(current_step)

    # Advance to next step
    @sequence.advance_step!

    # Schedule next email if sequence is still active
    schedule_next_email if @sequence.reload.active?
  rescue StandardError => e
    Rails.logger.error("EmailSequenceJob failed for sequence #{email_sequence_id}: #{e.message}")
    @sequence.pause! if @sequence
  end

  private

  def send_welcome_sequence(step)
    case step
    when 0
      # Immediate welcome email
      LeadNotificationMailer.welcome_email(@lead).deliver_now
    when 1..4
      # Additional welcome series emails
      LeadNotificationMailer.nurture_email(@lead, step).deliver_now
    end
  end

  def send_nurture_sequence(step)
    # Educational content emails
    LeadNotificationMailer.nurture_email(@lead, step + 1).deliver_now
  end

  def send_qualification_sequence(step)
    # Qualification and requirement gathering emails
    LeadNotificationMailer.qualification_email(@lead, step + 1).deliver_now
  end

  def send_proposal_sequence(step)
    # Proposal follow-up emails
    LeadNotificationMailer.proposal_email(@lead, step + 1).deliver_now
  end

  def send_follow_up_sequence(step)
    # Follow-up emails for inactive leads
    LeadNotificationMailer.follow_up_email(@lead, step + 1).deliver_now
  end

  def send_reengagement_sequence(step)
    # Re-engagement emails for cold leads
    LeadNotificationMailer.reengagement_email(@lead, step + 1).deliver_now
  end

  def track_email_sent(step)
    @lead.analytics.create!(
      event_type: 'email_sent',
      source: @sequence.sequence_name,
      metadata: {
        sequence_name: @sequence.sequence_name,
        step: step,
        sent_at: Time.current
      }
    )
  end

  def schedule_next_email
    next_send_time = @sequence.next_email_date

    EmailSequenceJob.set(wait_until: next_send_time).perform_later(@sequence.id)
  end
end