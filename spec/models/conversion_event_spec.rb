require "rails_helper"

RSpec.describe ConversionEvent, type: :model do
  describe "associations" do
    it { should belong_to(:lead) }
  end

  describe "validations" do
    it { should validate_presence_of(:event_type) }
    it { should validate_presence_of(:converted_at) }
  end

  describe "callbacks" do
    describe "#calculate_time_to_convert" do
      let(:lead) { create(:lead, created_at: 2.days.ago) }
      let(:conversion_event) { build(:conversion_event, lead: lead, converted_at: Time.current) }

      it "calculates time_to_convert in seconds on create" do
        conversion_event.save
        expect(conversion_event.time_to_convert).to be_within(5).of(2.days.to_i)
      end

      it "handles nil converted_at gracefully" do
        conversion_event.converted_at = nil
        expect(conversion_event.save).to be false
        expect(conversion_event.errors[:converted_at]).to include("can't be blank")
      end
    end
  end

  describe "scopes" do
    let(:lead) { create(:lead) }
    let!(:form_conversion) { create(:conversion_event, lead: lead, event_type: "form_submit", value: 100) }
    let!(:email_conversion) { create(:conversion_event, lead: lead, event_type: "email_conversion", value: 200) }
    let!(:purchase_conversion) { create(:conversion_event, lead: lead, event_type: "purchase", value: 500) }

    describe ".by_event_type" do
      it "filters conversion events by type" do
        results = ConversionEvent.by_event_type("form_submit")
        expect(results).to include(form_conversion)
        expect(results).not_to include(email_conversion, purchase_conversion)
      end
    end

    describe ".recent" do
      it "orders conversion events by converted_at descending" do
        results = ConversionEvent.recent
        expect(results.first.converted_at).to be >= results.last.converted_at
      end
    end

    describe ".for_date_range" do
      let!(:old_conversion) { create(:conversion_event, lead: lead, converted_at: 2.weeks.ago) }
      let!(:recent_conversion) { create(:conversion_event, lead: lead, converted_at: 1.day.ago) }

      it "filters conversions within date range" do
        results = ConversionEvent.for_date_range(3.days.ago, Time.current)
        expect(results).to include(recent_conversion)
        expect(results).not_to include(old_conversion)
      end
    end

    describe ".this_week" do
      let!(:this_week_conversion) { create(:conversion_event, lead: lead, converted_at: 2.days.ago) }
      let!(:last_week_conversion) { create(:conversion_event, lead: lead, converted_at: 8.days.ago) }

      it "returns conversions from current week" do
        results = ConversionEvent.this_week
        expect(results).to include(this_week_conversion)
        expect(results).not_to include(last_week_conversion)
      end
    end

    describe ".this_month" do
      let!(:this_month_conversion) { create(:conversion_event, lead: lead, converted_at: 5.days.ago) }
      let!(:last_month_conversion) { create(:conversion_event, lead: lead, converted_at: 35.days.ago) }

      it "returns conversions from current month" do
        results = ConversionEvent.this_month
        expect(results).to include(this_month_conversion)
        expect(results).not_to include(last_month_conversion)
      end
    end
  end

  describe ".total_value" do
    let(:lead) { create(:lead) }

    before do
      create(:conversion_event, lead: lead, value: 100)
      create(:conversion_event, lead: lead, value: 200)
      create(:conversion_event, lead: lead, value: 300)
    end

    it "returns sum of all conversion values" do
      expect(ConversionEvent.total_value).to eq(600)
    end

    it "returns 0 when no conversions exist" do
      ConversionEvent.delete_all
      expect(ConversionEvent.total_value).to eq(0)
    end
  end

  describe ".average_time_to_convert" do
    let(:lead) { create(:lead) }

    before do
      create(:conversion_event, lead: lead, time_to_convert: 100)
      create(:conversion_event, lead: lead, time_to_convert: 200)
      create(:conversion_event, lead: lead, time_to_convert: 300)
    end

    it "returns average time to convert in seconds" do
      expect(ConversionEvent.average_time_to_convert).to eq(200)
    end

    it "returns 0 when no conversions exist" do
      ConversionEvent.delete_all
      expect(ConversionEvent.average_time_to_convert).to eq(0)
    end
  end

  describe "#time_to_convert_in_days" do
    let(:lead) { create(:lead) }

    it "converts seconds to days" do
      conversion = create(:conversion_event, lead: lead, time_to_convert: 2.days.to_i)
      expect(conversion.time_to_convert_in_days).to be_within(0.1).of(2.0)
    end

    it "returns 0 when time_to_convert is nil" do
      conversion = create(:conversion_event, lead: lead, time_to_convert: nil)
      expect(conversion.time_to_convert_in_days).to eq(0)
    end
  end
end
