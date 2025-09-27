require 'rails_helper'

RSpec.describe BlogAuthor, type: :model do
  describe 'associations' do
    it { should have_many(:blog_posts).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_uniqueness_of(:slug) }
  end

  describe 'friendly_id' do
    let(:author) { create(:blog_author, name: 'John Doe') }

    it 'generates slug from name' do
      expect(author.slug).to eq('john-doe')
    end

    it 'can be found by slug' do
      author # force creation
      expect(author.slug).to eq('john-doe')
      expect(BlogAuthor.friendly.find('john-doe')).to eq(author)
    end
  end

  describe '#profile_url' do
    let(:author) { create(:blog_author, slug: 'john-doe') }

    it 'returns the author profile URL' do
      expect(author.profile_url).to include('/authors/john-doe')
    end
  end

  describe '#posts_count' do
    let(:author) { create(:blog_author) }

    it 'returns the number of posts by the author' do
      create_list(:blog_post, 3, author: author)
      expect(author.posts_count).to eq(3)
    end
  end
end