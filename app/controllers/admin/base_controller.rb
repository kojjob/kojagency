module Admin
  class BaseController < ApplicationController
    before_action :authenticate_admin!
    before_action :authorize_admin_access!
    layout 'admin'

    protected

    # Override in specific controllers to restrict certain actions
    def authorize_action!
      # Super admins can perform all actions
      return true if super_admin_signed_in?

      # Regular admins have restrictions on certain models
      # Override this method in specific controllers to add restrictions
      true
    end

    # Helper method to check if current user can perform CRUD operations
    def can_manage?(model_name = nil)
      # Super admins can manage everything
      return true if super_admin_signed_in?

      # Regular admins can manage most things except User model
      if model_name == 'User'
        false
      else
        admin_signed_in?
      end
    end

    # Add this as a before_action in controllers that need model-specific authorization
    def authorize_model_access!
      model_name = controller_name.classify
      unless can_manage?(model_name)
        redirect_to admin_root_path, alert: "You don't have permission to manage #{model_name.pluralize}"
      end
    end

    helper_method :can_manage?, :super_admin_signed_in?
  end
end