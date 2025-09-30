require 'rails_helper'

RSpec.describe Service, type: :model do
  describe 'associations' do
    it { should have_many(:project_services).dependent(:destroy) }
    it { should have_many(:projects).through(:project_services) }
  end

  describe 'validations' do
    subject { build(:service) }

    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }

    it { should validate_uniqueness_of(:slug).case_insensitive }
    it { should validate_length_of(:name).is_at_most(100) }
    it { should validate_length_of(:description).is_at_least(50).is_at_most(2000) }
  end

  describe 'friendly_id' do
    it 'generates slug from name' do
      service = create(:service, name: 'Web Development')
      expect(service.slug).to eq('web-development')
    end

    it 'finds service by slug' do
      service = create(:service, name: 'Mobile Development')
      found = Service.friendly.find('mobile-development')
      expect(found).to eq(service)
    end
  end

  describe 'instance methods' do
    let(:service) { create(:service, features: "Feature 1\nFeature 2\nFeature 3") }

    describe '#features_list' do
      it 'returns features as an array' do
        expect(service.features_list).to eq(['Feature 1', 'Feature 2', 'Feature 3'])
      end

      it 'returns empty array when features is nil' do
        service.update(features: nil)
        expect(service.features_list).to eq([])
      end

      it 'removes empty lines' do
        service.update(features: "Feature 1\n\nFeature 2\n\n")
        expect(service.features_list).to eq(['Feature 1', 'Feature 2'])
      end
    end
  end
end