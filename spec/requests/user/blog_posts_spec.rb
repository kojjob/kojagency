require 'rails_helper'

RSpec.describe "User::BlogPosts", type: :request do
  let(:user) { create(:user) }
  let(:admin) { create(:user, role: :admin) }
  let(:other_user) { create(:user) }
  let(:blog_post) { create(:user_blog_post, user_author: user) }
  let(:other_user_post) { create(:user_blog_post, user_author: other_user) }

  describe "when not logged in" do
    describe "GET /user/blog_posts" do
      it "redirects to login" do
        get user_blog_posts_path, as: :html
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    describe "GET /user/blog_posts/new" do
      it "redirects to login" do
        get new_user_blog_post_path, as: :html
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "when logged in as regular user" do
    before { sign_in user }

    describe "GET /user/blog_posts" do
      let!(:user_posts) { create_list(:blog_post, 3, :with_user_author, author: user) }
      let!(:other_posts) { create_list(:blog_post, 2, :with_user_author, author: other_user) }

      it "shows only current user's posts" do
        get user_blog_posts_path, as: :html
        expect(response).to have_http_status(:success)
        expect(response.body).to include(user_posts.first.title)
        expect(response.body).not_to include(other_posts.first.title)
      end
    end

    describe "GET /user/blog_posts/new" do
      it "shows the new post form" do
        get new_user_blog_post_path, as: :html
        expect(response).to have_http_status(:success)
        expect(response.body).to include("New Blog Post")
      end
    end

    describe "POST /user/blog_posts" do
      let(:valid_attributes) do
        {
          title: "My Test Post",
          content: "This is a test post content",
          excerpt: "Test excerpt",
          status: "draft"
        }
      end

      it "creates a new blog post for the current user" do
        expect {
          post user_blog_posts_path, params: { blog_post: valid_attributes }
        }.to change(BlogPost, :count).by(1)

        created_post = BlogPost.last
        expect(created_post.author).to eq(user)
        expect(created_post.title).to eq("My Test Post")
      end

      it "redirects to the created post" do
        post user_blog_posts_path, params: { blog_post: valid_attributes }
        expect(response).to redirect_to(user_blog_post_path(BlogPost.last))
      end
    end

    describe "GET /user/blog_posts/:id" do
      it "shows the user's own post" do
        get user_blog_post_path(blog_post), as: :html
        expect(response).to have_http_status(:success)
        expect(response.body).to include(blog_post.title)
      end

      it "forbids access to other user's posts" do
        get user_blog_post_path(other_user_post), as: :html
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "GET /user/blog_posts/:id/edit" do
      it "shows the edit form for user's own post" do
        get edit_user_blog_post_path(blog_post), as: :html
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Edit Blog Post")
      end

      it "forbids editing other user's posts" do
        get edit_user_blog_post_path(other_user_post), as: :html
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "PATCH /user/blog_posts/:id" do
      let(:update_attributes) { { title: "Updated Title", content: "Updated content" } }

      it "updates the user's own post" do
        patch user_blog_post_path(blog_post), params: { blog_post: update_attributes }
        blog_post.reload
        expect(blog_post.title).to eq("Updated Title")
        expect(response).to redirect_to(user_blog_post_path(blog_post))
      end

      it "forbids updating other user's posts" do
        patch user_blog_post_path(other_user_post), params: { blog_post: update_attributes }
        expect(response).to have_http_status(:forbidden)
      end
    end

    describe "DELETE /user/blog_posts/:id" do
      it "deletes the user's own post" do
        blog_post # Create the post
        expect {
          delete user_blog_post_path(blog_post)
        }.to change(BlogPost, :count).by(-1)
      end

      it "forbids deleting other user's posts" do
        other_user_post # Create the post
        expect {
          delete user_blog_post_path(other_user_post)
        }.not_to change(BlogPost, :count)
        expect(response).to have_http_status(:forbidden)
      end
    end
  end

  describe "when logged in as admin" do
    before { sign_in admin }

    describe "GET /user/blog_posts" do
      let!(:admin_posts) { create_list(:blog_post, 2, :with_user_author, author: admin) }
      let!(:user_posts) { create_list(:blog_post, 3, :with_user_author, author: user) }

      it "shows only admin's own posts in user section" do
        get user_blog_posts_path, as: :html
        expect(response).to have_http_status(:success)
        expect(response.body).to include(admin_posts.first.title)
        expect(response.body).not_to include(user_posts.first.title)
      end
    end

    it "can access admin section separately" do
      get admin_blog_posts_path, as: :html
      expect(response).to have_http_status(:success)
    end
  end
end