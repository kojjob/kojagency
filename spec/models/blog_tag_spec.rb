require 'rails_helper'

RSpec.describe BlogTag, type: :model do
  describe 'associations' do
    it { should have_many(:blog_post_tags).dependent(:destroy) }
    it { should have_many(:posts).through(:blog_post_tags).source(:blog_post) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).case_insensitive }
    it { should validate_uniqueness_of(:slug) }
  end

  describe 'scopes' do
    describe '.popular' do
      let!(:popular_tag) { create(:blog_tag, usage_count: 100) }
      let!(:unpopular_tag) { create(:blog_tag, usage_count: 5) }

      it 'orders tags by usage_count desc' do
        expect(BlogTag.popular.first).to eq(popular_tag)
        expect(BlogTag.popular.last).to eq(unpopular_tag)
      end
    end

    describe '.used' do
      let!(:used_tag) { create(:blog_tag, usage_count: 10) }
      let!(:unused_tag) { create(:blog_tag, usage_count: 0) }

      it 'returns only tags with usage_count > 0' do
        expect(BlogTag.used).to include(used_tag)
        expect(BlogTag.used).not_to include(unused_tag)
      end
    end
  end

  describe 'friendly_id' do
    let(:tag) { create(:blog_tag, name: 'Ruby on Rails') }

    it 'generates slug from name' do
      expect(tag.slug).to eq('ruby-on-rails')
    end

    it 'can be found by slug' do
      tag # force creation
      expect(tag.slug).to eq('ruby-on-rails')
      expect(BlogTag.friendly.find('ruby-on-rails')).to eq(tag)
    end
  end

  describe '#update_usage_count' do
    let(:tag) { create(:blog_tag) }

    it 'updates usage_count based on associated posts' do
      create_list(:blog_post_tag, 3, blog_tag: tag)
      tag.update_usage_count

      expect(tag.reload.usage_count).to eq(3)
    end
  end

  describe 'callbacks' do
    describe 'before_save' do
      let(:tag) { build(:blog_tag, name: ' Ruby on Rails ') }

      it 'normalizes name before save' do
        tag.save
        expect(tag.name).to eq('Ruby on Rails')
      end

      it 'downcases slug' do
        tag.name = 'UPPERCASE TAG'
        tag.save
        expect(tag.slug).to eq('uppercase-tag')
      end
    end
  end
end