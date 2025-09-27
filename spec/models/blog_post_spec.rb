require 'rails_helper'

RSpec.describe BlogPost, type: :model do
  describe 'associations' do
    it { should belong_to(:author) }
    it { should belong_to(:category).class_name('BlogCategory').optional }
    it { should have_many(:blog_post_tags).dependent(:destroy) }
    it { should have_many(:tags).through(:blog_post_tags).source(:blog_tag) }
    it { should have_many(:blog_media_attachments).dependent(:destroy) }
    it { should have_many(:media).through(:blog_media_attachments).source(:blog_media) }
    it { should have_many(:blog_related_posts).dependent(:destroy) }
    it { should have_many(:related_posts).through(:blog_related_posts).source(:related_post) }
    it { should have_one_attached(:featured_image) }
    it { should have_rich_text(:rich_content) }
  end

  describe 'validations' do
    subject { build(:blog_post) }

    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(255) }
    it { should validate_presence_of(:content) }
    # Slug is auto-generated from title, so presence is not directly validated
    it { should validate_uniqueness_of(:slug) }
    it { should validate_length_of(:meta_description).is_at_most(160).allow_blank }
    it { should validate_length_of(:meta_title).is_at_most(60).allow_blank }
    it { should validate_inclusion_of(:status).in_array(%w[draft published scheduled archived]) }
    it { should validate_length_of(:country_code).is_equal_to(2).allow_blank }
  end

  describe 'scopes' do
    let!(:published_post) { create(:blog_post, status: 'published', published_at: 1.day.ago) }
    let!(:scheduled_post) { create(:blog_post, status: 'scheduled', published_at: 1.day.from_now) }
    let!(:draft_post) { create(:blog_post, status: 'draft') }
    let!(:archived_post) { create(:blog_post, status: 'archived') }
    let!(:future_published) { create(:blog_post, status: 'published', published_at: 1.hour.from_now) }

    describe '.published' do
      it 'returns only published posts with past published_at date' do
        expect(BlogPost.published).to include(published_post)
        expect(BlogPost.published).not_to include(scheduled_post, draft_post, archived_post, future_published)
      end
    end

    describe '.scheduled' do
      it 'returns posts scheduled for the future' do
        expect(BlogPost.scheduled).to include(scheduled_post)
        expect(BlogPost.scheduled).not_to include(published_post, draft_post, archived_post)
      end
    end

    describe '.draft' do
      it 'returns only draft posts' do
        expect(BlogPost.draft).to include(draft_post)
        expect(BlogPost.draft).not_to include(published_post, scheduled_post, archived_post)
      end
    end

    describe '.archived' do
      it 'returns only archived posts' do
        expect(BlogPost.archived).to include(archived_post)
        expect(BlogPost.archived).not_to include(published_post, scheduled_post, draft_post)
      end
    end

    describe '.recent' do
      it 'orders posts by published_at desc' do
        BlogPost.destroy_all # Clean up any existing posts
        older_post = create(:blog_post, status: 'published', published_at: 2.days.ago)
        newer_post = create(:blog_post, status: 'published', published_at: 1.hour.ago)

        result = BlogPost.recent.to_a
        expect(result.first.id).to eq(newer_post.id)
        expect(result.last.id).to eq(older_post.id)
      end
    end

    describe '.popular' do
      it 'orders posts by views_count desc' do
        BlogPost.destroy_all # Clean up any existing posts
        low_views = create(:blog_post, views_count: 10, shares_count: 5)
        high_views = create(:blog_post, views_count: 100, shares_count: 20)
        medium_views = create(:blog_post, views_count: 50, shares_count: 10)

        result = BlogPost.popular
        expect(result.first.id).to eq(high_views.id)
        expect(result.second.id).to eq(medium_views.id)
        expect(result.third.id).to eq(low_views.id)
      end
    end
  end

  describe 'GEO targeting' do
    describe '.in_country' do
      let!(:us_post) { create(:blog_post, country_code: 'US') }
      let!(:uk_post) { create(:blog_post, country_code: 'UK') }

      it 'returns posts for specified country' do
        expect(BlogPost.in_country('US')).to include(us_post)
        expect(BlogPost.in_country('US')).not_to include(uk_post)
      end
    end

    describe '.in_region' do
      let!(:ca_post) { create(:blog_post, region: 'California') }
      let!(:ny_post) { create(:blog_post, region: 'New York') }

      it 'returns posts for specified region' do
        expect(BlogPost.in_region('California')).to include(ca_post)
        expect(BlogPost.in_region('California')).not_to include(ny_post)
      end
    end

    describe '.in_city' do
      let!(:sf_post) { create(:blog_post, city: 'San Francisco') }
      let!(:la_post) { create(:blog_post, city: 'Los Angeles') }

      it 'returns posts for specified city' do
        expect(BlogPost.in_city('San Francisco')).to include(sf_post)
        expect(BlogPost.in_city('San Francisco')).not_to include(la_post)
      end
    end
  end

  describe 'SEO features' do
    let(:post) { build(:blog_post, title: 'Test Post Title') }

    describe '#generate_slug' do
      it 'generates SEO-friendly slug from title' do
        post.slug = nil
        post.save
        expect(post.slug).to eq('test-post-title')
      end

      it 'does not override existing slug' do
        post.slug = 'custom-slug'
        post.save
        expect(post.slug).to eq('custom-slug')
      end
    end

    describe '#seo_title' do
      it 'returns meta_title if present' do
        post.meta_title = 'Custom SEO Title'
        expect(post.seo_title).to eq('Custom SEO Title')
      end

      it 'falls back to title if meta_title is blank' do
        post.meta_title = nil
        expect(post.seo_title).to eq(post.title)
      end
    end

    describe '#seo_description' do
      it 'returns meta_description if present' do
        post.meta_description = 'Custom meta description'
        expect(post.seo_description).to eq('Custom meta description')
      end

      it 'falls back to excerpt if meta_description is blank' do
        post.meta_description = nil
        post.excerpt = 'Post excerpt'
        expect(post.seo_description).to eq('Post excerpt')
      end

      it 'falls back to truncated content if both are blank' do
        post.meta_description = nil
        post.excerpt = nil
        post.content = 'A' * 200
        expect(post.seo_description.length).to be <= 160
      end
    end

    describe '#structured_data' do
      before do
        post.save
        allow(post).to receive(:canonical_url_with_fallback).and_return('https://example.com/blog/test-post')
      end

      it 'returns valid JSON-LD structured data' do
        data = JSON.parse(post.structured_data)

        expect(data['@context']).to eq('https://schema.org')
        expect(data['@type']).to eq('Article')
        expect(data['headline']).to eq(post.title)
        expect(data['author']['name']).to eq(post.author.name)
      end
    end
  end

  describe '#reading_time' do
    let(:post) { build(:blog_post) }

    it 'calculates reading time based on word count' do
      post.content = 'word ' * 250  # 250 words
      post.save
      expect(post.reading_time).to eq(1)
    end

    it 'rounds up for partial minutes' do
      post.content = 'word ' * 300  # 300 words
      post.save
      expect(post.reading_time).to eq(2)
    end
  end

  describe '#publish!' do
    let(:post) { create(:blog_post, status: 'draft') }

    it 'updates status to published' do
      post.publish!
      expect(post.status).to eq('published')
    end

    it 'sets published_at to current time' do
      freeze_time do
        post.publish!
        expect(post.published_at).to eq(Time.current)
      end
    end
  end

  describe '#archive!' do
    let(:post) { create(:blog_post, status: 'published') }

    it 'updates status to archived' do
      post.archive!
      expect(post.status).to eq('archived')
    end
  end

  describe '#published?' do
    it 'returns true for published posts with past published_at' do
      post = build(:blog_post, status: 'published', published_at: 1.day.ago)
      expect(post.published?).to be true
    end

    it 'returns false for published posts with future published_at' do
      post = build(:blog_post, status: 'published', published_at: 1.day.from_now)
      expect(post.published?).to be false
    end

    it 'returns false for non-published status' do
      post = build(:blog_post, status: 'draft', published_at: 1.day.ago)
      expect(post.published?).to be false
    end
  end

  describe '#scheduled?' do
    it 'returns true for scheduled posts' do
      post = build(:blog_post, status: 'scheduled', published_at: 1.day.from_now)
      expect(post.scheduled?).to be true
    end

    it 'returns true for published posts with future published_at' do
      post = build(:blog_post, status: 'published', published_at: 1.day.from_now)
      expect(post.scheduled?).to be true
    end

    it 'returns false for published posts with past published_at' do
      post = build(:blog_post, status: 'published', published_at: 1.day.ago)
      expect(post.scheduled?).to be false
    end
  end

  describe 'media associations' do
    let(:post) { create(:blog_post) }
    let(:image) { create(:blog_media, media_type: 'image') }
    let(:video) { create(:blog_media, media_type: 'video') }
    let(:document) { create(:blog_media, media_type: 'document') }

    before do
      post.media << [image, video, document]
    end

    describe '#images' do
      it 'returns only image media' do
        expect(post.images).to include(image)
        expect(post.images).not_to include(video, document)
      end
    end

    describe '#videos' do
      it 'returns only video media' do
        expect(post.videos).to include(video)
        expect(post.videos).not_to include(image, document)
      end
    end

    describe '#documents' do
      it 'returns only document media' do
        expect(post.documents).to include(document)
        expect(post.documents).not_to include(image, video)
      end
    end
  end

  describe '#increment_views!' do
    let(:post) { create(:blog_post, views_count: 0) }

    it 'increments views_count by 1' do
      expect { post.increment_views! }.to change { post.reload.views_count }.by(1)
    end
  end

  describe 'callbacks' do
    describe 'before_save callbacks' do
      let(:post) { build(:blog_post) }

      it 'calculates reading time before save' do
        post.content = 'word ' * 500
        post.save
        expect(post.reading_time).to eq(2)
      end

      it 'sets published_at when publishing' do
        post.status = 'published'
        post.published_at = nil
        post.save
        expect(post.published_at).to be_present
      end
    end

    describe 'geocoding' do
      let(:post) { create(:blog_post) }

      it 'geocodes when location changes', :vcr do
        post.update(city: 'San Francisco', region: 'CA', country_code: 'US')
        expect(post.latitude).to be_present
        expect(post.longitude).to be_present
      end
    end
  end

  describe 'friendly_id' do
    let(:post) { create(:blog_post, title: 'Test Blog Post', slug: 'test-blog-post') }

    it 'uses slug for friendly_id' do
      expect(post.friendly_id).to eq('test-blog-post')
    end

    it 'can be found by slug' do
      post.reload # Ensure it's saved in DB
      found_post = BlogPost.friendly.find('test-blog-post')
      expect(found_post.id).to eq(post.id)
    end
  end

  describe 'class methods' do
    describe '.for_sitemap' do
      let!(:post) { create(:blog_post, status: 'published') }

      it 'returns minimal data for sitemap generation' do
        result = BlogPost.for_sitemap.first
        expect(result.attributes.keys).to include('id', 'slug', 'updated_at')
      end
    end

    describe '.trending' do
      let!(:recent_popular) { create(:blog_post, status: 'published', published_at: 1.day.ago, views_count: 100, shares_count: 50) }
      let!(:recent_unpopular) { create(:blog_post, status: 'published', published_at: 2.days.ago, views_count: 10, shares_count: 5) }
      let!(:old_popular) { create(:blog_post, status: 'published', published_at: 2.weeks.ago, views_count: 200, shares_count: 100) }

      it 'returns recent posts ordered by popularity' do
        trending = BlogPost.trending(2)
        expect(trending).to include(recent_popular, recent_unpopular)
        expect(trending).not_to include(old_popular)
        expect(trending.first).to eq(recent_popular)
      end
    end
  end
end