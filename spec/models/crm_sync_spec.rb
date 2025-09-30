require "rails_helper"

RSpec.describe CrmSync, type: :model do
  describe "associations" do
    it { should belong_to(:lead) }
  end

  describe "validations" do
    it { should validate_presence_of(:crm_system) }
    it { should validate_presence_of(:sync_status) }

    it "validates crm_system inclusion" do
      valid_systems = %w[hubspot salesforce]
      valid_systems.each do |system|
        sync = build(:crm_sync, crm_system: system)
        expect(sync).to be_valid
      end

      invalid_sync = build(:crm_sync, crm_system: "invalid_system")
      expect(invalid_sync).not_to be_valid
      expect(invalid_sync.errors[:crm_system]).to include("invalid_system is not a valid CRM system")
    end

    it "validates uniqueness of crm_system per lead" do
      lead = create(:lead)
      create(:crm_sync, lead: lead, crm_system: "hubspot")

      duplicate_sync = build(:crm_sync, lead: lead, crm_system: "hubspot")
      expect(duplicate_sync).not_to be_valid
      expect(duplicate_sync.errors[:crm_system]).to include("has already been taken")
    end
  end

  describe "enums" do
    it "defines sync_status enum" do
      expect(CrmSync.sync_statuses).to eq(
        "pending" => 0,
        "syncing" => 1,
        "synced" => 2,
        "failed" => 3
      )
    end
  end

  describe "scopes" do
    let(:lead) { create(:lead) }
    let!(:pending_sync) { create(:crm_sync, lead: lead, sync_status: "pending", crm_system: "hubspot") }
    let!(:synced_sync) { create(:crm_sync, lead: lead, sync_status: "synced", crm_system: "salesforce") }
    let!(:failed_sync) { create(:crm_sync, lead: lead, sync_status: "failed") }

    describe ".pending" do
      it "returns only pending syncs" do
        results = CrmSync.pending
        expect(results).to include(pending_sync)
        expect(results).not_to include(synced_sync, failed_sync)
      end
    end

    describe ".failed" do
      it "returns only failed syncs" do
        results = CrmSync.failed
        expect(results).to include(failed_sync)
        expect(results).not_to include(pending_sync, synced_sync)
      end
    end

    describe ".by_crm_system" do
      it "filters syncs by CRM system" do
        results = CrmSync.by_crm_system("hubspot")
        expect(results).to include(pending_sync)
        expect(results).not_to include(synced_sync)
      end
    end

    describe ".recent" do
      it "orders syncs by created_at descending" do
        results = CrmSync.recent
        expect(results.first.created_at).to be >= results.last.created_at
      end
    end

    describe ".needs_retry" do
      let!(:retry_needed) { create(:crm_sync, sync_status: "failed", metadata: { "retry_count" => 1 }) }
      let!(:max_retries) { create(:crm_sync, sync_status: "failed", metadata: { "retry_count" => 3 }) }

      it "returns failed syncs with retry_count less than 3" do
        results = CrmSync.needs_retry
        expect(results).to include(retry_needed)
        expect(results).not_to include(max_retries)
      end
    end
  end

  describe "#mark_as_synced!" do
    let(:sync) { create(:crm_sync, sync_status: "syncing") }

    it "updates status to synced" do
      sync.mark_as_synced!("crm-123")
      expect(sync.sync_status).to eq("synced")
    end

    it "sets crm_id" do
      sync.mark_as_synced!("crm-123")
      expect(sync.crm_id).to eq("crm-123")
    end

    it "sets last_synced_at timestamp" do
      sync.mark_as_synced!("crm-123")
      expect(sync.last_synced_at).to be_within(1.second).of(Time.current)
    end

    it "clears sync_error" do
      sync.update(sync_error: "Previous error")
      sync.mark_as_synced!("crm-123")
      expect(sync.sync_error).to be_nil
    end
  end

  describe "#mark_as_failed!" do
    let(:sync) { create(:crm_sync, sync_status: "syncing", metadata: {}) }

    it "updates status to failed" do
      sync.mark_as_failed!("Connection error")
      expect(sync.sync_status).to eq("failed")
    end

    it "sets sync_error message" do
      sync.mark_as_failed!("Connection error")
      expect(sync.sync_error).to eq("Connection error")
    end

    it "increments retry_count in metadata" do
      sync.mark_as_failed!("Connection error")
      expect(sync.metadata["retry_count"]).to eq(1)

      sync.mark_as_failed!("Connection error")
      expect(sync.metadata["retry_count"]).to eq(2)
    end

    it "preserves existing metadata" do
      sync.metadata = { "custom_field" => "value" }
      sync.save
      sync.mark_as_failed!("Connection error")
      expect(sync.metadata["custom_field"]).to eq("value")
    end
  end

  describe "#retry_sync!" do
    let(:sync) { create(:crm_sync, sync_status: "failed", sync_error: "Previous error") }

    it "updates status to pending" do
      sync.retry_sync!
      expect(sync.sync_status).to eq("pending")
    end

    it "clears sync_error" do
      sync.retry_sync!
      expect(sync.sync_error).to be_nil
    end
  end

  describe "#retry_count" do
    it "returns retry count from metadata" do
      sync = create(:crm_sync, metadata: { "retry_count" => 2 })
      expect(sync.retry_count).to eq(2)
    end

    it "returns 0 when retry_count not set" do
      sync = create(:crm_sync, metadata: {})
      expect(sync.retry_count).to eq(0)
    end

    it "returns 0 when metadata is nil" do
      sync = create(:crm_sync, metadata: nil)
      expect(sync.retry_count).to eq(0)
    end
  end

  describe "#can_retry?" do
    it "returns true when retry_count is less than 3" do
      sync = create(:crm_sync, sync_status: "failed", metadata: { "retry_count" => 2 })
      expect(sync.can_retry?).to be true
    end

    it "returns false when retry_count equals 3" do
      sync = create(:crm_sync, sync_status: "failed", metadata: { "retry_count" => 3 })
      expect(sync.can_retry?).to be false
    end

    it "returns false when retry_count exceeds 3" do
      sync = create(:crm_sync, sync_status: "failed", metadata: { "retry_count" => 5 })
      expect(sync.can_retry?).to be false
    end
  end

  describe "#time_since_last_sync" do
    it "returns duration in seconds since last sync" do
      sync = create(:crm_sync, last_synced_at: 2.hours.ago)
      expect(sync.time_since_last_sync).to be_within(5).of(2.hours.to_i)
    end

    it "returns nil when never synced" do
      sync = create(:crm_sync, last_synced_at: nil)
      expect(sync.time_since_last_sync).to be_nil
    end
  end

  describe "#sync_age_in_hours" do
    it "returns hours since last sync" do
      sync = create(:crm_sync, last_synced_at: 3.hours.ago)
      expect(sync.sync_age_in_hours).to be_within(0.1).of(3.0)
    end

    it "returns 0 when never synced" do
      sync = create(:crm_sync, last_synced_at: nil)
      expect(sync.sync_age_in_hours).to eq(0.0)
    end
  end

  describe "#status_color" do
    it "returns green for synced status" do
      sync = create(:crm_sync, sync_status: "synced")
      expect(sync.status_color).to eq("green")
    end

    it "returns blue for syncing status" do
      sync = create(:crm_sync, sync_status: "syncing")
      expect(sync.status_color).to eq("blue")
    end

    it "returns red for failed status" do
      sync = create(:crm_sync, sync_status: "failed")
      expect(sync.status_color).to eq("red")
    end

    it "returns yellow for pending status" do
      sync = create(:crm_sync, sync_status: "pending")
      expect(sync.status_color).to eq("yellow")
    end
  end
end
