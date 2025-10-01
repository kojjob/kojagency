class LeadNotificationMailer < ApplicationMailer
  default from: ENV.fetch("ADMIN_EMAIL", "noreply@kojagency.com")

  # Admin notification when new lead is created
  def new_lead_notification(lead)
    @lead = lead
    @admin_lead_url = admin_lead_url(@lead)

    admin_emails = ENV.fetch("ADMIN_EMAILS", "admin@kojagency.com").split(",")

    mail(
      to: admin_emails,
      subject: "New #{@lead.priority_level.upcase} Priority Lead: #{@lead.full_name} - #{@lead.project_type_display}"
    )
  end

  # Welcome email - sent immediately after lead creation
  def welcome_email(lead)
    @lead = lead
    @company_name = ENV.fetch("COMPANY_NAME", "KOJ Agency")

    mail(
      to: @lead.email,
      subject: "Thank you for contacting #{@company_name}"
    )
  end

  # Nurture email - educational content to build trust
  def nurture_email(lead, step)
    @lead = lead
    @step = step
    @company_name = ENV.fetch("COMPANY_NAME", "KOJ Agency")

    subject = case step
    when 1
                "How we approach #{@lead.project_type_display} projects"
    when 2
                "Case study: Similar #{@lead.project_type_display} projects we've completed"
    when 3
                "Technical insights for your #{@lead.project_type_display} project"
    else
                "More about #{@company_name} and our process"
    end

    mail(
      to: @lead.email,
      subject: subject
    )
  end

  # Qualification email - gather more requirements
  def qualification_email(lead, step)
    @lead = lead
    @step = step
    @company_name = ENV.fetch("COMPANY_NAME", "KOJ Agency")

    subject = case step
    when 1
                "Let's discuss your #{@lead.project_type_display} project in detail"
    when 2
                "Technical requirements for your project"
    when 3
                "Timeline and budget considerations"
    else
                "Next steps for your project"
    end

    mail(
      to: @lead.email,
      subject: subject
    )
  end

  # Proposal follow-up emails
  def proposal_email(lead, step)
    @lead = lead
    @step = step
    @company_name = ENV.fetch("COMPANY_NAME", "KOJ Agency")

    subject = case step
    when 1
                "Your custom proposal for #{@lead.project_type_display}"
    when 2
                "Questions about your proposal?"
    when 3
                "Let's schedule a call to discuss"
    else
                "Ready to move forward?"
    end

    mail(
      to: @lead.email,
      subject: subject
    )
  end

  # Follow-up emails for inactive leads
  def follow_up_email(lead, step)
    @lead = lead
    @step = step
    @company_name = ENV.fetch("COMPANY_NAME", "KOJ Agency")

    subject = case step
    when 1
                "Following up on your #{@lead.project_type_display} inquiry"
    when 2
                "Still interested in #{@lead.project_type_display}?"
    when 3
                "Any updates on your project plans?"
    else
                "We're here when you're ready"
    end

    mail(
      to: @lead.email,
      subject: subject
    )
  end

  # Re-engagement emails for cold leads
  def reengagement_email(lead, step)
    @lead = lead
    @step = step
    @company_name = ENV.fetch("COMPANY_NAME", "KOJ Agency")

    subject = case step
    when 1
                "New capabilities for #{@lead.project_type_display} projects"
    when 2
                "Special offer: #{@lead.project_type_display} consultation"
    else
                "Would you like to reconnect?"
    end

    mail(
      to: @lead.email,
      subject: subject
    )
  end
end
