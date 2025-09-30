require 'rails_helper'

RSpec.describe Blog::CategoriesController, type: :controller do
  let(:blog_category) { create(:blog_category) }

  describe 'GET #index' do
    before do
      create_list(:blog_category, 5)
    end

    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns all categories' do
      get :index
      expect(assigns(:categories).count).to eq(5)
    end

    it 'orders categories by name' do
      create(:blog_category, name: 'Alpha')
      create(:blog_category, name: 'Zulu')

      get :index
      categories = assigns(:categories)
      expect(categories.first.name).to eq('Alpha')
      expect(categories.last.name).to eq('Zulu')
    end

    it 'includes post counts' do
      category_with_posts = create(:blog_category)
      create_list(:blog_post, 3, :published, category: category_with_posts)

      get :index
      category = assigns(:categories).find { |c| c.id == category_with_posts.id }
      expect(category.posts_count).to eq(3)
    end
  end

  describe 'GET #show' do
    before do
      create_list(:blog_post, 3, :published, category: blog_category)
      create(:blog_post, status: 'draft', category: blog_category) # Should not appear
    end

    it 'returns a success response' do
      get :show, params: { id: blog_category.slug }
      expect(response).to be_successful
    end

    it 'assigns the requested category' do
      get :show, params: { id: blog_category.slug }
      expect(assigns(:category)).to eq(blog_category)
    end

    it 'assigns published posts in the category' do
      get :show, params: { id: blog_category.slug }
      expect(assigns(:posts).count).to eq(3)
    end

    it 'paginates posts' do
      create_list(:blog_post, 15, :published, category: blog_category)
      get :show, params: { id: blog_category.slug, page: 2 }
      expect(assigns(:posts).count).to be <= 12
    end

    it 'sets SEO meta tags' do
      get :show, params: { id: blog_category.slug }
      expect(assigns(:meta_tags)).to include(
        title: "#{blog_category.name} - Blog",
        description: blog_category.description
      )
    end

    context 'with non-existent category' do
      it 'returns 404' do
        expect {
          get :show, params: { id: 'non-existent' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
