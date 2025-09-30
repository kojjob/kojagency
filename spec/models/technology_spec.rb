require 'rails_helper'

RSpec.describe Technology, type: :model do
  describe 'associations' do
    it { should have_many(:project_technologies).dependent(:destroy) }
    it { should have_many(:projects).through(:project_technologies) }
  end

  describe 'validations' do
    subject { build(:technology) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:category) }

    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should validate_length_of(:name).is_at_most(100) }
    it { should validate_length_of(:description).is_at_most(1000) }
  end

  describe 'scopes' do
    let!(:frontend_tech) { create(:technology, category: 'Frontend') }
    let!(:backend_tech) { create(:technology, category: 'Backend') }
    let!(:database_tech) { create(:technology, category: 'Database') }

    describe '.by_category' do
      it 'returns technologies in specified category' do
        expect(Technology.by_category('Frontend')).to eq([frontend_tech])
        expect(Technology.by_category('Backend')).to eq([backend_tech])
      end
    end

    describe '.ordered_by_name' do
      it 'returns technologies ordered alphabetically' do
        tech_a = create(:technology, name: 'Angular')
        tech_z = create(:technology, name: 'Zend')
        tech_m = create(:technology, name: 'MongoDB')

        expect(Technology.ordered_by_name.pluck(:name)).to eq(['Angular', 'MongoDB', 'Zend', frontend_tech.name, backend_tech.name, database_tech.name].sort)
      end
    end
  end
end