require "rails_helper"

RSpec.describe EmailSequence, type: :model do
  describe "associations" do
    it { should belong_to(:lead) }
  end

  describe "validations" do
    it { should validate_presence_of(:sequence_name) }
    it { should validate_presence_of(:status) }

    it "validates sequence_name inclusion" do
      valid_names = %w[welcome nurture reengagement winback upgrade followup]
      valid_names.each do |name|
        sequence = build(:email_sequence, sequence_name: name)
        expect(sequence).to be_valid
      end

      invalid_sequence = build(:email_sequence, sequence_name: "invalid_name")
      expect(invalid_sequence).not_to be_valid
      expect(invalid_sequence.errors[:sequence_name]).to include("invalid_name is not a valid sequence")
    end

    it "validates uniqueness of sequence_name per lead" do
      lead = create(:lead)
      create(:email_sequence, lead: lead, sequence_name: "welcome")

      duplicate_sequence = build(:email_sequence, lead: lead, sequence_name: "welcome")
      expect(duplicate_sequence).not_to be_valid
      expect(duplicate_sequence.errors[:sequence_name]).to include("has already been taken")
    end
  end

  describe "enums" do
    it "defines status enum" do
      expect(EmailSequence.statuses).to eq(
        "active" => 0,
        "paused" => 1,
        "completed" => 2,
        "cancelled" => 3
      )
    end
  end

  describe "callbacks" do
    describe "#set_started_at" do
      it "sets started_at timestamp on creation" do
        sequence = create(:email_sequence)
        expect(sequence.started_at).to be_within(1.second).of(Time.current)
      end
    end
  end

  describe "scopes" do
    let(:lead) { create(:lead) }
    let!(:active_sequence) { create(:email_sequence, lead: lead, status: "active", sequence_name: "welcome") }
    let!(:paused_sequence) { create(:email_sequence, lead: lead, status: "paused", sequence_name: "nurture") }
    let!(:completed_sequence) { create(:email_sequence, lead: lead, status: "completed", sequence_name: "followup") }

    describe ".active" do
      it "returns only active sequences" do
        results = EmailSequence.active
        expect(results).to include(active_sequence)
        expect(results).not_to include(paused_sequence, completed_sequence)
      end
    end

    describe ".by_sequence_name" do
      it "filters sequences by name" do
        results = EmailSequence.by_sequence_name("welcome")
        expect(results).to include(active_sequence)
        expect(results).not_to include(paused_sequence, completed_sequence)
      end
    end

    describe ".recent" do
      it "orders sequences by created_at descending" do
        results = EmailSequence.recent
        expect(results.first.created_at).to be >= results.last.created_at
      end
    end
  end

  describe "state machine methods" do
    let(:sequence) { create(:email_sequence, status: "active", current_step: 0) }

    describe "#advance_step!" do
      it "increments current_step" do
        expect { sequence.advance_step! }.to change { sequence.current_step }.from(0).to(1)
      end

      it "updates updated_at timestamp" do
        freeze_time do
          travel 1.day
          expect { sequence.advance_step! }.to change { sequence.updated_at }
        end
      end
    end

    describe "#pause!" do
      it "sets status to paused" do
        expect { sequence.pause! }.to change { sequence.status }.from("active").to("paused")
      end
    end

    describe "#resume!" do
      it "sets status back to active" do
        sequence.pause!
        expect { sequence.resume! }.to change { sequence.status }.from("paused").to("active")
      end
    end

    describe "#complete!" do
      it "sets status to completed" do
        expect { sequence.complete! }.to change { sequence.status }.from("active").to("completed")
      end

      it "sets completed_at timestamp" do
        sequence.complete!
        expect(sequence.completed_at).to be_within(1.second).of(Time.current)
      end
    end

    describe "#cancel!" do
      it "sets status to cancelled" do
        expect { sequence.cancel! }.to change { sequence.status }.from("active").to("cancelled")
      end
    end
  end

  describe "#progress_percentage" do
    let(:sequence) { create(:email_sequence) }

    context "when total_steps is greater than 0" do
      before { sequence.metadata["total_steps"] = 5 }

      it "returns percentage based on current_step" do
        sequence.current_step = 2
        expect(sequence.progress_percentage).to eq(40.0)
      end

      it "returns 0 when current_step is 0" do
        sequence.current_step = 0
        expect(sequence.progress_percentage).to eq(0.0)
      end

      it "returns 100 when current_step equals total_steps" do
        sequence.current_step = 5
        expect(sequence.progress_percentage).to eq(100.0)
      end
    end

    context "when total_steps is 0 or nil" do
      it "returns 0" do
        sequence.metadata["total_steps"] = 0
        expect(sequence.progress_percentage).to eq(0.0)
      end

      it "returns 0 when total_steps is not set" do
        sequence.metadata = {}
        expect(sequence.progress_percentage).to eq(0.0)
      end
    end
  end

  describe "#duration_in_days" do
    let(:sequence) { create(:email_sequence) }

    it "returns duration from started_at to now" do
      sequence.update(started_at: 5.days.ago)
      expect(sequence.duration_in_days).to be_within(0.1).of(5.0)
    end

    it "returns 0 when started_at is nil" do
      sequence.update(started_at: nil)
      expect(sequence.duration_in_days).to eq(0.0)
    end
  end

  describe "#next_email_at" do
    let(:sequence) { create(:email_sequence) }

    it "returns scheduled time for next email" do
      next_time = 2.days.from_now
      sequence.metadata["next_email_at"] = next_time.iso8601
      expect(sequence.next_email_at).to be_within(1.second).of(next_time)
    end

    it "returns nil when next_email_at is not set" do
      sequence.metadata = {}
      expect(sequence.next_email_at).to be_nil
    end
  end
end
