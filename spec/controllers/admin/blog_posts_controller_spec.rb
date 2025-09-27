require 'rails_helper'

RSpec.describe Admin::BlogPostsController, type: :controller do
  let(:admin_user) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:blog_post) { create(:blog_post) }
  let(:blog_author) { create(:blog_author) }
  let(:blog_category) { create(:blog_category) }

  describe 'authentication' do
    it 'requires admin authentication' do
      get :index
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('Admin access required')
    end

    it 'denies access to non-admin users' do
      session[:user_id] = regular_user.id
      get :index
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq('Not authorized')
    end
  end

  context 'when authenticated as admin' do
    before { session[:user_id] = admin_user.id }

    describe 'GET #index' do
      before do
        create_list(:blog_post, 3, status: 'published')
        create_list(:blog_post, 2, status: 'draft')
      end

      it 'returns a success response' do
        get :index
        expect(response).to be_successful
      end

      it 'assigns all posts (not just published)' do
        get :index
        expect(assigns(:posts).count).to eq(5)
      end

      it 'filters by status' do
        get :index, params: { status: 'draft' }
        expect(assigns(:posts).count).to eq(2)
        expect(assigns(:posts).all? { |p| p.status == 'draft' }).to be true
      end

      it 'searches posts' do
        create(:blog_post, title: 'Ruby Tutorial')
        create(:blog_post, title: 'Python Guide')

        get :index, params: { q: 'ruby' }
        expect(assigns(:posts).count).to eq(1)
      end

      it 'paginates results' do
        create_list(:blog_post, 25)
        get :index, params: { page: 2 }
        expect(assigns(:posts).count).to be <= 20
      end
    end

    describe 'GET #new' do
      it 'returns a success response' do
        get :new
        expect(response).to be_successful
      end

      it 'assigns a new post' do
        get :new
        expect(assigns(:post)).to be_a_new(BlogPost)
      end

      it 'loads authors and categories' do
        create_list(:blog_author, 3)
        create_list(:blog_category, 5)

        get :new
        expect(assigns(:authors).count).to eq(3)
        expect(assigns(:categories).count).to eq(5)
      end
    end

    describe 'POST #create' do
      let(:valid_attributes) do
        {
          title: 'New Blog Post',
          content: 'Interesting content here',
          author_id: blog_author.id,
          category_id: blog_category.id,
          status: 'draft'
        }
      end

      let(:invalid_attributes) do
        {
          title: '',
          content: '',
          author_id: nil
        }
      end

      context 'with valid params' do
        it 'creates a new BlogPost' do
          expect {
            post :create, params: { blog_post: valid_attributes }
          }.to change(BlogPost, :count).by(1)
        end

        it 'redirects to the created post' do
          post :create, params: { blog_post: valid_attributes }
          expect(response).to redirect_to(admin_blog_post_path(BlogPost.last))
        end

        it 'sets a success flash message' do
          post :create, params: { blog_post: valid_attributes }
          expect(flash[:notice]).to eq('Blog post was successfully created.')
        end

        it 'handles tag associations' do
          tag1 = create(:blog_tag)
          tag2 = create(:blog_tag)

          post :create, params: {
            blog_post: valid_attributes.merge(tag_ids: [tag1.id, tag2.id])
          }

          new_post = BlogPost.last
          expect(new_post.tags).to include(tag1, tag2)
        end
      end

      context 'with invalid params' do
        it 'does not create a new BlogPost' do
          expect {
            post :create, params: { blog_post: invalid_attributes }
          }.not_to change(BlogPost, :count)
        end

        it 'returns a success response (renders new)' do
          post :create, params: { blog_post: invalid_attributes }
          expect(response).to be_successful
        end
      end
    end

    describe 'GET #edit' do
      it 'returns a success response' do
        get :edit, params: { id: blog_post.slug }
        expect(response).to be_successful
      end

      it 'assigns the requested post' do
        get :edit, params: { id: blog_post.slug }
        expect(assigns(:post)).to eq(blog_post)
      end

      it 'loads authors and categories' do
        create_list(:blog_author, 3)
        create_list(:blog_category, 5)

        get :edit, params: { id: blog_post.slug }
        expect(assigns(:authors).count).to be >= 3
        expect(assigns(:categories).count).to be >= 5
      end
    end

    describe 'PUT #update' do
      let(:new_attributes) do
        {
          title: 'Updated Title',
          status: 'published'
        }
      end

      context 'with valid params' do
        it 'updates the requested post' do
          put :update, params: { id: blog_post.slug, blog_post: new_attributes }
          blog_post.reload
          expect(blog_post.title).to eq('Updated Title')
          expect(blog_post.status).to eq('published')
        end

        it 'redirects to the post' do
          put :update, params: { id: blog_post.slug, blog_post: new_attributes }
          expect(response).to redirect_to(admin_blog_post_path(blog_post))
        end

        it 'sets a success flash message' do
          put :update, params: { id: blog_post.slug, blog_post: new_attributes }
          expect(flash[:notice]).to eq('Blog post was successfully updated.')
        end
      end

      context 'with invalid params' do
        it 'does not update the post' do
          original_title = blog_post.title
          put :update, params: { id: blog_post.slug, blog_post: { title: '' } }
          blog_post.reload
          expect(blog_post.title).to eq(original_title)
        end

        it 'returns a success response (renders edit)' do
          put :update, params: { id: blog_post.slug, blog_post: { title: '' } }
          expect(response).to be_successful
        end
      end
    end

    describe 'DELETE #destroy' do
      it 'destroys the requested post' do
        blog_post # Create the post
        expect {
          delete :destroy, params: { id: blog_post.slug }
        }.to change(BlogPost, :count).by(-1)
      end

      it 'redirects to the posts list' do
        delete :destroy, params: { id: blog_post.slug }
        expect(response).to redirect_to(admin_blog_posts_path)
      end

      it 'sets a success flash message' do
        delete :destroy, params: { id: blog_post.slug }
        expect(flash[:notice]).to eq('Blog post was successfully deleted.')
      end
    end

    describe 'POST #publish' do
      let(:draft_post) { create(:blog_post, status: 'draft') }

      it 'publishes the post' do
        post :publish, params: { id: draft_post.slug }
        draft_post.reload
        expect(draft_post.status).to eq('published')
        expect(draft_post.published_at).to be_present
      end

      it 'redirects back with success message' do
        post :publish, params: { id: draft_post.slug }
        expect(response).to redirect_to(admin_blog_posts_path)
        expect(flash[:notice]).to eq('Blog post was successfully published.')
      end
    end

    describe 'POST #archive' do
      let(:published_post) { create(:blog_post, :published) }

      it 'archives the post' do
        post :archive, params: { id: published_post.slug }
        published_post.reload
        expect(published_post.status).to eq('archived')
      end

      it 'redirects back with success message' do
        post :archive, params: { id: published_post.slug }
        expect(response).to redirect_to(admin_blog_posts_path)
        expect(flash[:notice]).to eq('Blog post was successfully archived.')
      end
    end

    describe 'GET #preview' do
      it 'returns a success response' do
        get :preview, params: { id: blog_post.slug }
        expect(response).to be_successful
      end

      it 'renders without layout' do
        get :preview, params: { id: blog_post.slug }
        expect(response).to render_template(layout: false)
      end

      it 'can preview draft posts' do
        draft = create(:blog_post, status: 'draft')
        get :preview, params: { id: draft.slug }
        expect(response).to be_successful
      end
    end
  end
end