require 'rails_helper'

RSpec.describe BlogCategory, type: :model do
  describe 'associations' do
    it { should have_many(:blog_posts).dependent(:nullify) }
    it { should belong_to(:parent).class_name('BlogCategory').optional }
    it { should have_many(:subcategories).class_name('BlogCategory').with_foreign_key('parent_id') }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_uniqueness_of(:slug) }
  end

  describe 'scopes' do
    describe '.top_level' do
      let!(:parent) { create(:blog_category, parent: nil) }
      let!(:child) { create(:blog_category, parent: parent) }

      it 'returns only categories without parent' do
        expect(BlogCategory.top_level).to include(parent)
        expect(BlogCategory.top_level).not_to include(child)
      end
    end

    describe '.with_posts' do
      let!(:category_with_posts) { create(:blog_category) }
      let!(:category_without_posts) { create(:blog_category) }

      before do
        create(:blog_post, category: category_with_posts, status: 'published')
      end

      it 'returns only categories with published posts' do
        expect(BlogCategory.with_posts).to include(category_with_posts)
        expect(BlogCategory.with_posts).not_to include(category_without_posts)
      end
    end
  end

  describe 'friendly_id' do
    let(:category) { create(:blog_category, name: 'Web Development') }

    it 'generates slug from name' do
      expect(category.slug).to eq('web-development')
    end

    it 'can be found by slug' do
      category # force creation
      expect(category.slug).to eq('web-development')
      expect(BlogCategory.friendly.find('web-development')).to eq(category)
    end
  end

  describe '#posts_count' do
    let(:category) { create(:blog_category) }

    it 'returns count of published posts' do
      create_list(:blog_post, 2, category: category, status: 'published', published_at: 1.day.ago)
      create(:blog_post, category: category, status: 'draft')

      expect(category.posts_count).to eq(2)
    end
  end

  describe '#full_path' do
    let(:parent) { create(:blog_category, name: 'Technology') }
    let(:child) { create(:blog_category, name: 'Programming', parent: parent) }
    let(:grandchild) { create(:blog_category, name: 'Ruby', parent: child) }

    it 'returns hierarchical path for nested categories' do
      expect(grandchild.full_path).to eq('Technology > Programming > Ruby')
    end

    it 'returns single name for top-level category' do
      expect(parent.full_path).to eq('Technology')
    end
  end
end