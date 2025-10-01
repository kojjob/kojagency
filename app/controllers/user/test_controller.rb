class User::TestController < ApplicationController
  before_action :authenticate_user!

  def index
    render plain: "Authenticated user: #{current_user.email}"
  end
end
