require 'rails_helper'

RSpec.describe "Admin::BlogComments", type: :request do
  describe "GET /index" do
    it "returns http success" do
      get "/admin/blog_comments/index"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /approve" do
    it "returns http success" do
      get "/admin/blog_comments/approve"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /reject" do
    it "returns http success" do
      get "/admin/blog_comments/reject"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/admin/blog_comments/destroy"
      expect(response).to have_http_status(:success)
    end
  end

end
