require "rails_helper"

RSpec.describe Analytic, type: :model do
  describe "associations" do
    it { should belong_to(:lead) }
  end

  describe "validations" do
    it { should validate_presence_of(:event_type) }

    it "validates event_type inclusion" do
      valid_types = %w[page_view form_start form_submit email_open email_click conversion contact]
      valid_types.each do |type|
        analytic = build(:analytic, event_type: type)
        expect(analytic).to be_valid
      end

      invalid_analytic = build(:analytic, event_type: "invalid_type")
      expect(invalid_analytic).not_to be_valid
      expect(invalid_analytic.errors[:event_type]).to include("invalid_type is not a valid event type")
    end
  end

  describe "scopes" do
    let(:lead) { create(:lead) }
    let!(:page_view) { create(:analytic, lead: lead, event_type: "page_view", source: "google", campaign: "summer2024") }
    let!(:form_start) { create(:analytic, lead: lead, event_type: "form_start", source: "facebook", campaign: "winter2024") }
    let!(:conversion) { create(:analytic, lead: lead, event_type: "conversion", source: "google", campaign: "summer2024") }

    describe ".by_event_type" do
      it "filters analytics by event type" do
        results = Analytic.by_event_type("page_view")
        expect(results).to include(page_view)
        expect(results).not_to include(form_start, conversion)
      end
    end

    describe ".by_source" do
      it "filters analytics by source" do
        results = Analytic.by_source("google")
        expect(results).to include(page_view, conversion)
        expect(results).not_to include(form_start)
      end
    end

    describe ".by_campaign" do
      it "filters analytics by campaign" do
        results = Analytic.by_campaign("summer2024")
        expect(results).to include(page_view, conversion)
        expect(results).not_to include(form_start)
      end
    end

    describe ".recent" do
      it "orders analytics by created_at descending" do
        results = Analytic.recent
        expect(results.first.created_at).to be >= results.last.created_at
      end
    end

    describe ".for_date_range" do
      let!(:old_analytic) { create(:analytic, lead: lead, created_at: 2.weeks.ago) }
      let!(:recent_analytic) { create(:analytic, lead: lead, created_at: 1.day.ago) }

      it "filters analytics within date range" do
        results = Analytic.for_date_range(3.days.ago, Time.current)
        expect(results).to include(recent_analytic)
        expect(results).not_to include(old_analytic)
      end
    end

    describe ".this_week" do
      let!(:this_week_analytic) { create(:analytic, lead: lead, created_at: 2.days.ago) }
      let!(:last_week_analytic) { create(:analytic, lead: lead, created_at: 8.days.ago) }

      it "returns analytics from current week" do
        results = Analytic.this_week
        expect(results).to include(this_week_analytic)
        expect(results).not_to include(last_week_analytic)
      end
    end

    describe ".this_month" do
      let!(:this_month_analytic) { create(:analytic, lead: lead, created_at: 5.days.ago) }
      let!(:last_month_analytic) { create(:analytic, lead: lead, created_at: 35.days.ago) }

      it "returns analytics from current month" do
        results = Analytic.this_month
        expect(results).to include(this_month_analytic)
        expect(results).not_to include(last_month_analytic)
      end
    end
  end

  describe ".funnel_metrics" do
    let(:lead) { create(:lead) }

    before do
      create(:analytic, lead: lead, event_type: "page_view")
      create(:analytic, lead: lead, event_type: "page_view")
      create(:analytic, lead: lead, event_type: "form_start")
      create(:analytic, lead: lead, event_type: "form_submit")
      create(:analytic, lead: lead, event_type: "conversion")
    end

    it "returns funnel stage counts" do
      metrics = Analytic.funnel_metrics
      expect(metrics).to be_a(Hash)
      expect(metrics["page_view"]).to eq(2)
      expect(metrics["form_start"]).to eq(1)
      expect(metrics["form_submit"]).to eq(1)
      expect(metrics["conversion"]).to eq(1)
    end
  end

  describe ".top_sources" do
    let(:lead) { create(:lead) }

    before do
      create(:analytic, lead: lead, source: "google")
      create(:analytic, lead: lead, source: "google")
      create(:analytic, lead: lead, source: "facebook")
    end

    it "returns sources ordered by count" do
      results = Analytic.top_sources(10)
      expect(results).to be_an(Array)
      expect(results.first["source"]).to eq("google")
      expect(results.first["count"]).to eq(2)
    end
  end

  describe ".top_campaigns" do
    let(:lead) { create(:lead) }

    before do
      create(:analytic, lead: lead, campaign: "summer2024")
      create(:analytic, lead: lead, campaign: "summer2024")
      create(:analytic, lead: lead, campaign: "winter2024")
    end

    it "returns campaigns ordered by count" do
      results = Analytic.top_campaigns(10)
      expect(results).to be_an(Array)
      expect(results.first["campaign"]).to eq("summer2024")
      expect(results.first["count"]).to eq(2)
    end
  end
end
