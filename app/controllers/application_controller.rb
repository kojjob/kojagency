class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  # allow_browser versions: :modern  # Temporarily disabled to fix Devise authentication

  # Changes to the importmap will invalidate the etag for HTML responses
  # stale_when_importmap_changes  # Temporarily disabled to debug Devise

  # Devise will handle user authentication
  protect_from_forgery with: :exception

  # For backwards compatibility with existing admin system
  helper_method :admin_current_user, :admin_signed_in?

  private

  # Legacy authentication methods for admin system
  # If user is signed in with Devise and is an admin, use that for admin system too
  def admin_current_user
    if current_user&.admin?
      current_user
    else
      @admin_current_user ||= User.find(session[:admin_user_id]) if session[:admin_user_id]
    end
  rescue ActiveRecord::RecordNotFound
    session[:admin_user_id] = nil
    nil
  end

  def admin_signed_in?
    admin_current_user.present?
  end

  def authenticate_admin!
    unless admin_signed_in?
      redirect_to root_path, alert: 'Admin access required'
    end
  end

  def require_admin
    unless admin_current_user&.admin?
      redirect_to root_path, alert: 'Admin access required'
    end
  end

  # Method for controller tests compatibility
  def admin_sign_in(user)
    session[:admin_user_id] = user.id
    @admin_current_user = user
  end
end
