require 'rails_helper'

RSpec.describe Blog::TagsController, type: :controller do
  let(:blog_tag) { create(:blog_tag) }

  describe 'GET #index' do
    before do
      create_list(:blog_tag, 10)
    end

    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns popular tags' do
      popular_tag = create(:blog_tag, usage_count: 100)
      unpopular_tag = create(:blog_tag, usage_count: 1)

      get :index
      tags = assigns(:tags)
      expect(tags.first.id).to eq(popular_tag.id)
    end

    it 'limits to top 50 tags' do
      create_list(:blog_tag, 60)
      get :index
      expect(assigns(:tags).count).to eq(50)
    end

    it 'returns JSON format' do
      get :index, format: :json
      expect(response).to be_successful
      expect(response.content_type).to include('application/json')
    end
  end

  describe 'GET #show' do
    before do
      @post1 = create(:blog_post, :published)
      @post2 = create(:blog_post, :published)
      @post3 = create(:blog_post, status: 'draft')

      @post1.tags << blog_tag
      @post2.tags << blog_tag
      @post3.tags << blog_tag # Draft post should not appear
    end

    it 'returns a success response' do
      get :show, params: { id: blog_tag.slug }
      expect(response).to be_successful
    end

    it 'assigns the requested tag' do
      get :show, params: { id: blog_tag.slug }
      expect(assigns(:tag)).to eq(blog_tag)
    end

    it 'assigns published posts with the tag' do
      get :show, params: { id: blog_tag.slug }
      posts = assigns(:posts)
      expect(posts.count).to eq(2)
      expect(posts).to include(@post1, @post2)
      expect(posts).not_to include(@post3)
    end

    it 'paginates posts' do
      15.times do
        post = create(:blog_post, :published)
        post.tags << blog_tag
      end

      get :show, params: { id: blog_tag.slug, page: 2 }
      expect(assigns(:posts).count).to be <= 12
    end

    it 'sets SEO meta tags' do
      get :show, params: { id: blog_tag.slug }
      expect(assigns(:meta_tags)).to include(
        title: "Posts tagged with #{blog_tag.name}",
        description: "Browse all blog posts tagged with #{blog_tag.name}"
      )
    end

    it 'increments usage count' do
      expect {
        get :show, params: { id: blog_tag.slug }
      }.to change { blog_tag.reload.usage_count }.by(1)
    end

    context 'with non-existent tag' do
      it 'returns 404' do
        expect {
          get :show, params: { id: 'non-existent' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'GET #cloud' do
    before do
      create(:blog_tag, name: 'Popular', usage_count: 100)
      create(:blog_tag, name: 'Medium', usage_count: 50)
      create(:blog_tag, name: 'Rare', usage_count: 5)
    end

    it 'returns a success response' do
      get :cloud
      expect(response).to be_successful
    end

    it 'assigns tags with size weights' do
      get :cloud
      tags = assigns(:tag_cloud)

      popular = tags.find { |t| t.name == 'Popular' }
      medium = tags.find { |t| t.name == 'Medium' }
      rare = tags.find { |t| t.name == 'Rare' }

      expect(popular.weight).to be > medium.weight
      expect(medium.weight).to be > rare.weight
    end

    it 'returns JSON format' do
      get :cloud, format: :json
      expect(response).to be_successful
      expect(response.content_type).to include('application/json')

      data = JSON.parse(response.body)
      expect(data).to be_an(Array)
      expect(data.first).to have_key('name')
      expect(data.first).to have_key('weight')
      expect(data.first).to have_key('url')
    end
  end
end
