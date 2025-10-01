require 'rails_helper'

RSpec.describe "User::Test", type: :request do
  describe "GET /user/test" do
    context "when not logged in" do
      it "redirects to login" do
        get user_test_index_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "when logged in" do
      let(:user) { create(:user) }

      before { sign_in user }

      it "shows authenticated content" do
        get user_test_index_path, as: :html
        expect(response).to have_http_status(:success)
        expect(response.body).to include(user.email)
      end
    end
  end
end
