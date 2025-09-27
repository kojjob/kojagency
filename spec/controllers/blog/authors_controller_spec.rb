require 'rails_helper'

RSpec.describe Blog::AuthorsController, type: :controller do
  let(:blog_author) { create(:blog_author) }

  describe 'GET #index' do
    before do
      create_list(:blog_author, 5)
    end

    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end

    it 'assigns all authors' do
      get :index
      expect(assigns(:authors).count).to eq(5)
    end

    it 'orders authors by name' do
      create(:blog_author, name: 'Alice')
      create(:blog_author, name: 'Zoe')

      get :index
      authors = assigns(:authors)
      expect(authors.first.name).to eq('Alice')
      expect(authors.last.name).to eq('Zoe')
    end

    it 'includes post counts' do
      author_with_posts = create(:blog_author)
      create_list(:blog_post, 4, :published, author: author_with_posts)

      get :index
      author = assigns(:authors).find { |a| a.id == author_with_posts.id }
      expect(author.posts_count).to eq(4)
    end
  end

  describe 'GET #show' do
    before do
      create_list(:blog_post, 3, :published, author: blog_author)
      create(:blog_post, status: 'draft', author: blog_author) # Should not appear
    end

    it 'returns a success response' do
      get :show, params: { id: blog_author.slug }
      expect(response).to be_successful
    end

    it 'assigns the requested author' do
      get :show, params: { id: blog_author.slug }
      expect(assigns(:author)).to eq(blog_author)
    end

    it 'assigns published posts by the author' do
      get :show, params: { id: blog_author.slug }
      expect(assigns(:posts).count).to eq(3)
    end

    it 'paginates posts' do
      create_list(:blog_post, 15, :published, author: blog_author)
      get :show, params: { id: blog_author.slug, page: 2 }
      expect(assigns(:posts).count).to be <= 12
    end

    it 'sets SEO meta tags' do
      get :show, params: { id: blog_author.slug }
      expect(assigns(:meta_tags)).to include(
        title: "#{blog_author.name} - Author",
        description: blog_author.bio
      )
    end

    context 'with non-existent author' do
      it 'returns 404' do
        expect {
          get :show, params: { id: 'non-existent' }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end