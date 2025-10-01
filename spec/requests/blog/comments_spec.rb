require 'rails_helper'

RSpec.describe "Blog::Comments", type: :request do
  describe "GET /create" do
    it "returns http success" do
      get "/blog/comments/create"
      expect(response).to have_http_status(:success)
    end
  end

  describe "GET /destroy" do
    it "returns http success" do
      get "/blog/comments/destroy"
      expect(response).to have_http_status(:success)
    end
  end
end
