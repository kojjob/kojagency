class LeadNotificationMailer < ApplicationMailer
  default from: ENV.fetch('ADMIN_EMAIL', 'noreply@kojagency.com')

  def new_lead_notification(lead)
    @lead = lead
    @admin_lead_url = admin_lead_url(@lead)

    # Send to admin email (configured in environment)
    admin_emails = ENV.fetch('ADMIN_EMAILS', 'admin@kojagency.com').split(',')

    mail(
      to: admin_emails,
      subject: "New #{@lead.priority_level.upcase} Priority Lead: #{@lead.full_name} - #{@lead.project_type_display}"
    )
  end
end
