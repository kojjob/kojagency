require "rails_helper"

RSpec.describe LeadNotificationMailer, type: :mailer do
  describe "new_lead_notification" do
    let(:mail) { LeadNotificationMailer.new_lead_notification }

    it "renders the headers" do
      expect(mail.subject).to eq("New lead notification")
      expect(mail.to).to eq(["to@example.org"])
      expect(mail.from).to eq(["from@example.com"])
    end

    it "renders the body" do
      expect(mail.body.encoded).to match("Hi")
    end
  end

end
