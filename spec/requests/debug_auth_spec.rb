require 'rails_helper'

RSpec.describe "Debug Authentication", type: :request do
  describe "GET /user/test" do
    it "redirects to login when not authenticated" do
      get user_test_index_path

      puts "Response status: #{response.status}"
      puts "Response headers: #{response.headers.to_h}"
      puts "Response body: #{response.body}"
      puts "Request format: #{request.format}"

      # Now we expect the correct Devise behavior
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end