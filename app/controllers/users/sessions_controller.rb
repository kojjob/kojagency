# frozen_string_literal: true

class Users::SessionsController < Devise::SessionsController
  protected

  # The path used after sign in.
  def after_sign_in_path_for(resource)
    if resource.admin?
      admin_root_path
    else
      stored_location_for(resource) || root_path
    end
  end

  # The path used after sign out.
  def after_sign_out_path_for(resource_or_scope)
    root_path
  end
end
