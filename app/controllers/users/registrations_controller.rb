# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:name])
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    if resource.admin?
      admin_root_path
    else
      root_path
    end
  end

  # The path used after updating account.
  def after_update_path_for(resource)
    edit_user_registration_path
  end
end
