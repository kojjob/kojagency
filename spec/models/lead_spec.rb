require 'rails_helper'

RSpec.describe Lead, type: :model do
  let(:valid_attributes) do
    {
      first_name: "Alex",
      last_name: "Johnson",
      email: "alex.johnson@techcorp.com",
      phone: "+1-555-123-4567",
      company: "TechCorp Analytics",
      website: "https://techcorp-analytics.com",
      project_type: "data_engineering",
      budget: "100k_250k",
      timeline: "3_months",
      project_description: "We need to build a comprehensive data pipeline to process our customer analytics data from multiple sources including Salesforce, Google Analytics, and our proprietary mobile app.",
      preferred_contact_method: "email",
      source: "website"
    }
  end

  describe "validations" do
    subject { described_class.new(valid_attributes) }

    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:project_type) }
    it { should validate_presence_of(:budget) }
    it { should validate_presence_of(:timeline) }
    it { should validate_presence_of(:project_description) }
    it { should validate_presence_of(:source) }

    it { should validate_uniqueness_of(:email) }
    it { should validate_length_of(:first_name).is_at_most(50) }
    it { should validate_length_of(:last_name).is_at_most(50) }
    it { should validate_length_of(:company).is_at_most(100) }
    it { should validate_length_of(:project_description).is_at_least(20).is_at_most(2000) }

    it "validates email format" do
      subject.email = "invalid_email"
      expect(subject).not_to be_valid
      expect(subject.errors[:email]).to include("is invalid")
    end

    it "validates phone format" do
      subject.phone = "invalid_phone"
      expect(subject).not_to be_valid
      expect(subject.errors[:phone]).to include("must be a valid phone number")
    end

    it "validates project_type inclusion" do
      expect(subject).to validate_inclusion_of(:project_type).in_array(%w[web_development mobile_development data_engineering analytics_platform technical_consulting other])
    end

    it "validates budget inclusion" do
      expect(subject).to validate_inclusion_of(:budget).in_array(%w[under_10k 10k_25k 25k_50k 50k_100k 100k_250k 250k_plus])
    end

    it "validates timeline inclusion" do
      expect(subject).to validate_inclusion_of(:timeline).in_array(%w[asap 1_month 3_months 6_months 1_year flexible])
    end
  end

  describe "enums" do
    it "defines lead_status enum" do
      expect(described_class.lead_statuses).to eq({
        "pending" => 0,
        "contacted" => 1,
        "qualified" => 2,
        "proposal_sent" => 3,
        "negotiating" => 4,
        "won" => 5,
        "lost" => 6,
        "unqualified" => 7
      })
    end
  end

  describe "scopes" do
    let!(:high_score_lead) { create(:lead, :high_priority, email: "high@test.com", score: 85) }
    let!(:medium_score_lead) { create(:lead, :medium_priority, email: "medium@test.com", score: 70) }
    let!(:low_score_lead) { create(:lead, :low_priority, email: "low@test.com", score: 50) }

    it "filters high priority leads" do
      expect(described_class.high_priority).to include(high_score_lead)
      expect(described_class.high_priority).not_to include(medium_score_lead, low_score_lead)
    end

    it "filters medium priority leads" do
      expect(described_class.medium_priority).to include(medium_score_lead)
      expect(described_class.medium_priority).not_to include(high_score_lead, low_score_lead)
    end

    it "filters low priority leads" do
      expect(described_class.low_priority).to include(low_score_lead)
      expect(described_class.low_priority).not_to include(high_score_lead, medium_score_lead)
    end
  end

  describe "callbacks" do
    it "calculates score before save" do
      lead = described_class.new(valid_attributes.merge(email: "callback_test@test.com"))
      expect(lead.score).to eq(0.0)

      lead.save!
      expect(lead.score).to be > 0
      expect(lead.budget_score).to be > 0
      expect(lead.timeline_score).to be > 0
      expect(lead.complexity_score).to be > 0
      expect(lead.quality_score).to be > 0
    end
  end

  describe "instance methods" do
    let(:lead) { create(:lead, email: "instance_test@test.com") }

    describe "#full_name" do
      it "returns combined first and last name" do
        expect(lead.full_name).to eq("Alex Johnson")
      end
    end

    describe "#priority_level" do
      it "returns high for scores 80-100" do
        lead.update_column(:score, 85)
        expect(lead.priority_level).to eq("high")
      end

      it "returns medium for scores 60-79" do
        lead.update_column(:score, 70)
        expect(lead.priority_level).to eq("medium")
      end

      it "returns low for scores below 60" do
        lead.update_column(:score, 50)
        expect(lead.priority_level).to eq("low")
      end
    end

    describe "#priority_color" do
      it "returns red classes for high priority" do
        lead.update_column(:score, 85)
        expect(lead.priority_color).to eq("text-red-600 bg-red-100")
      end

      it "returns yellow classes for medium priority" do
        lead.update_column(:score, 70)
        expect(lead.priority_color).to eq("text-yellow-600 bg-yellow-100")
      end

      it "returns green classes for low priority" do
        lead.update_column(:score, 50)
        expect(lead.priority_color).to eq("text-green-600 bg-green-100")
      end
    end

    describe "#response_time_target" do
      it "returns immediate for high priority" do
        lead.update_column(:score, 85)
        expect(lead.response_time_target).to eq("Immediate (within 1 hour)")
      end

      it "returns priority for medium priority" do
        lead.update_column(:score, 70)
        expect(lead.response_time_target).to eq("Priority (within 2 hours)")
      end

      it "returns standard for low priority" do
        lead.update_column(:score, 50)
        expect(lead.response_time_target).to eq("Standard (within 24 hours)")
      end
    end

    describe "display methods" do
      it "displays budget range correctly" do
        expect(lead.budget_range_display).to eq("$100,000 - $250,000")
      end

      it "displays timeline correctly" do
        expect(lead.timeline_display).to eq("3 Months")
      end

      it "displays project type correctly" do
        expect(lead.project_type_display).to eq("Data Engineering")
      end
    end

    describe "#mark_as_contacted!" do
      it "updates contacted_at and lead_status" do
        expect {
          lead.mark_as_contacted!
        }.to change { lead.contacted_at }.from(nil)
          .and change { lead.lead_status }.from("pending").to("contacted")
      end
    end

    describe "#mark_as_qualified!" do
      it "updates qualified_at and lead_status" do
        expect {
          lead.mark_as_qualified!
        }.to change { lead.qualified_at }.from(nil)
          .and change { lead.lead_status }.from("pending").to("qualified")
      end
    end

    describe "#overdue_response?" do
      it "returns false for newly created leads" do
        expect(lead.overdue_response?).to be false
      end

      it "returns false for contacted leads" do
        lead.mark_as_contacted!
        expect(lead.overdue_response?).to be false
      end
    end
  end
end
