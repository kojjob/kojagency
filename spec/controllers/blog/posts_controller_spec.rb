require 'rails_helper'

RSpec.describe Blog::PostsController, type: :controller do
  let(:blog_post) { create(:blog_post, :published) }
  let(:draft_post) { create(:blog_post, status: 'draft') }
  let(:blog_category) { create(:blog_category) }
  let(:blog_tag) { create(:blog_tag) }

  describe 'GET #index' do
    before do
      create_list(:blog_post, 3, :published)
      create(:blog_post, status: 'draft') # Should not appear in index
    end

    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns published posts' do
      get :index
      expect(assigns(:posts).count).to eq(3)
    end

    it 'orders posts by recent' do
      old_post = create(:blog_post, :published, published_at: 1.week.ago)
      new_post = create(:blog_post, :published, published_at: 1.hour.ago)

      get :index
      posts = assigns(:posts)
      expect(posts.first.id).to eq(new_post.id)
    end

    it 'paginates posts' do
      create_list(:blog_post, 15, :published)
      get :index, params: { page: 2 }
      expect(assigns(:posts).count).to be <= 12
    end

    context 'with category filter' do
      it 'filters posts by category' do
        category = create(:blog_category)
        create(:blog_post, :published, category: category)
        create(:blog_post, :published) # Different category

        get :index, params: { category: category.slug }
        expect(assigns(:posts).count).to eq(1)
      end
    end

    context 'with tag filter' do
      it 'filters posts by tag' do
        tag = create(:blog_tag)
        post_with_tag = create(:blog_post, :published)
        post_with_tag.tags << tag
        create(:blog_post, :published) # Without tag

        get :index, params: { tag: tag.slug }
        expect(assigns(:posts).count).to eq(1)
      end
    end

    context 'with search query' do
      it 'searches posts by title and content' do
        create(:blog_post, :published, title: 'Ruby on Rails Tutorial')
        create(:blog_post, :published, content: 'Learning Rails is fun')
        create(:blog_post, :published, title: 'Python Guide')

        get :index, params: { q: 'rails' }
        expect(assigns(:posts).count).to eq(2)
      end
    end
  end

  describe 'GET #show' do
    context 'with published post' do
      it 'returns a success response' do
        get :show, params: { id: blog_post.slug }
        expect(response).to be_successful
      end

      it 'assigns the requested post' do
        get :show, params: { id: blog_post.slug }
        expect(assigns(:post)).to eq(blog_post)
      end

      it 'increments view count' do
        expect {
          get :show, params: { id: blog_post.slug }
        }.to change { blog_post.reload.views_count }.by(1)
      end

      it 'assigns related posts' do
        related_post = create(:blog_post, :published, category: blog_post.category)
        unrelated_post = create(:blog_post, :published)

        get :show, params: { id: blog_post.slug }
        expect(assigns(:related_posts)).to include(related_post)
        expect(assigns(:related_posts)).not_to include(unrelated_post)
      end

      it 'sets SEO meta tags' do
        get :show, params: { id: blog_post.slug }
        expect(assigns(:meta_tags)).to include(
          title: blog_post.seo_title,
          description: blog_post.seo_description
        )
      end
    end

    context 'with draft post' do
      it 'returns 404' do
        expect {
          get :show, params: { id: draft_post.slug }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'with non-existent post' do
      it 'returns 404' do
        expect {
          get :show, params: { id: 'non-existent' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'GET #feed' do
    before do
      create_list(:blog_post, 5, :published)
    end

    it 'returns RSS feed' do
      get :feed, format: :rss
      expect(response).to be_successful
      expect(response.content_type).to include('application/rss+xml')
    end

    it 'includes recent posts' do
      get :feed, format: :rss
      expect(assigns(:posts).count).to eq(5)
    end

    it 'orders posts by recent' do
      old_post = create(:blog_post, :published, published_at: 1.week.ago)
      new_post = create(:blog_post, :published, published_at: 1.hour.ago)

      get :feed, format: :rss
      posts = assigns(:posts)
      expect(posts.first.id).to eq(new_post.id)
    end
  end

  describe 'GET #sitemap' do
    before do
      create_list(:blog_post, 10, :published)
    end

    it 'returns XML sitemap' do
      get :sitemap, format: :xml
      expect(response).to be_successful
      expect(response.content_type).to include('application/xml')
    end

    it 'includes all published posts' do
      get :sitemap, format: :xml
      expect(assigns(:posts).count).to eq(10)
    end
  end

  describe 'POST #subscribe' do
    it 'creates a new subscription' do
      expect {
        post :subscribe, params: { email: 'test@example.com' }
      }.to change(BlogSubscription, :count).by(1)
    end

    it 'returns success JSON' do
      post :subscribe, params: { email: 'test@example.com' }
      expect(response).to be_successful
      expect(JSON.parse(response.body)['status']).to eq('success')
    end

    it 'handles invalid email' do
      post :subscribe, params: { email: 'invalid' }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['status']).to eq('error')
    end

    it 'handles duplicate subscription' do
      create(:blog_subscription, email: 'test@example.com')

      post :subscribe, params: { email: 'test@example.com' }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(JSON.parse(response.body)['message']).to include('already subscribed')
    end
  end
end
