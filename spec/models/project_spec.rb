require 'rails_helper'

RSpec.describe Project, type: :model do
  describe 'associations' do
    it { should have_many(:project_technologies).dependent(:destroy) }
    it { should have_many(:technologies).through(:project_technologies) }
    it { should have_many(:project_services).dependent(:destroy) }
    it { should have_many(:services).through(:project_services) }
    it { should have_one_attached(:featured_image) }
    it { should have_many_attached(:gallery_images) }
  end

  describe 'validations' do
    subject { build(:project) }

    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:client_name) }
    it { should validate_presence_of(:status) }

    it { should validate_length_of(:title).is_at_most(200) }
    it { should validate_length_of(:description).is_at_least(50).is_at_most(5000) }
    it { should validate_length_of(:client_name).is_at_most(100) }

    it { should validate_uniqueness_of(:slug).case_insensitive }

    context 'URL validations' do
      it 'validates project_url format when present' do
        project = build(:project, project_url: 'invalid-url')
        expect(project).not_to be_valid
        expect(project.errors[:project_url]).to include('must be a valid URL')
      end

      it 'allows valid project_url' do
        project = build(:project, project_url: 'https://example.com')
        expect(project).to be_valid
      end

      it 'allows nil project_url' do
        project = build(:project, project_url: nil)
        expect(project).to be_valid
      end
    end

    context 'numeric validations' do
      it { should validate_numericality_of(:duration_months).is_greater_than(0).allow_nil }
      it { should validate_numericality_of(:team_size).is_greater_than(0).allow_nil }
    end
  end

  describe 'enums' do
    it { should define_enum_for(:status).with_values(draft: 0, published: 1, archived: 2) }
  end

  describe 'friendly_id' do
    it 'generates slug from title' do
      project = create(:project, title: 'My Test Project')
      expect(project.slug).to eq('my-test-project')
    end

    it 'maintains slug when title changes' do
      project = create(:project, title: 'Original Title')
      original_slug = project.slug
      project.update(title: 'Updated Title')
      # FriendlyId keeps the original slug by default (unless should_generate_new_friendly_id? returns true)
      expect(project.slug).to eq(original_slug)
      expect(Project.friendly.find(original_slug)).to eq(project)
    end

    it 'finds project by slug' do
      project = create(:project, title: 'Find Me')
      found = Project.friendly.find('find-me')
      expect(found).to eq(project)
    end
  end

  describe 'scopes' do
    let!(:published_project) { create(:project, status: :published) }
    let!(:draft_project) { create(:project, status: :draft) }
    let!(:featured_project) { create(:project, status: :published, featured: true) }
    let!(:recent_project) { create(:project, status: :published, completion_date: 1.week.ago) }
    let!(:old_project) { create(:project, status: :published, completion_date: 2.years.ago) }

    describe '.published' do
      it 'returns only published projects' do
        expect(Project.published).to include(published_project, featured_project)
        expect(Project.published).not_to include(draft_project)
      end
    end

    describe '.featured' do
      it 'returns only featured projects' do
        expect(Project.featured).to eq([featured_project])
      end
    end

    describe '.recent' do
      it 'returns projects ordered by completion_date desc' do
        results = Project.recent.to_a
        # Verify the most recent project comes first
        expect(results.first).to eq(recent_project)
        # Verify the oldest project comes last
        expect(results.last).to eq(old_project)
        # Verify all projects are included
        expect(results).to include(recent_project, published_project, featured_project, draft_project, old_project)
      end
    end

    describe '.completed_after' do
      it 'returns projects completed after specified date' do
        date = 1.month.ago
        expect(Project.completed_after(date)).to include(recent_project)
        expect(Project.completed_after(date)).not_to include(old_project)
      end
    end
  end

  describe 'instance methods' do
    let(:project) { create(:project, duration_months: 6, team_size: 4) }

    describe '#display_duration' do
      it 'returns formatted duration' do
        expect(project.display_duration).to eq('6 months')
      end

      it 'returns singular for 1 month' do
        project.update(duration_months: 1)
        expect(project.display_duration).to eq('1 month')
      end

      it 'returns N/A when duration is nil' do
        project.update(duration_months: nil)
        expect(project.display_duration).to eq('N/A')
      end
    end

    describe '#display_team_size' do
      it 'returns formatted team size' do
        expect(project.display_team_size).to eq('4 people')
      end

      it 'returns singular for 1 person' do
        project.update(team_size: 1)
        expect(project.display_team_size).to eq('1 person')
      end

      it 'returns N/A when team size is nil' do
        project.update(team_size: nil)
        expect(project.display_team_size).to eq('N/A')
      end
    end

    describe '#formatted_completion_date' do
      it 'returns formatted date' do
        project.update(completion_date: Date.new(2024, 3, 15))
        expect(project.formatted_completion_date).to eq('March 2024')
      end

      it 'returns N/A when date is nil' do
        project.update(completion_date: nil)
        expect(project.formatted_completion_date).to eq('N/A')
      end
    end
  end
end