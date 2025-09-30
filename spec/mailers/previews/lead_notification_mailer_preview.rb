# Preview all emails at http://localhost:3000/rails/mailers/lead_notification_mailer
class LeadNotificationMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/lead_notification_mailer/new_lead_notification
  def new_lead_notification
    LeadNotificationMailer.new_lead_notification
  end

end
