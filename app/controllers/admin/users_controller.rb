module Admin
  class UsersController < BaseController
    before_action :require_super_admin, only: [:new, :create, :edit, :update, :destroy]
    before_action :set_user, only: [:show, :edit, :update, :destroy]

    def index
      @users = User.includes(:blog_posts, :blog_comments)
                   .order(created_at: :desc)
                   .page(params[:page])

      # Filter by role if specified
      @users = @users.where(role: params[:role]) if params[:role].present?

      # Search functionality
      if params[:q].present?
        @users = @users.where('email LIKE ? OR name LIKE ?', "%#{params[:q]}%", "%#{params[:q]}%")
      end
    end

    def show
      @recent_posts = @user.blog_posts.recent.limit(5)
      @recent_comments = @user.blog_comments.recent.limit(10)
    end

    def new
      @user = User.new
    end

    def create
      @user = User.new(user_params)

      if @user.save
        redirect_to admin_users_path, notice: 'User was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      # Prevent downgrading own super admin status
      if @user == current_user && @user.super_admin? && user_params[:role] != 'super_admin'
        redirect_to admin_users_path, alert: 'You cannot remove your own super admin privileges.'
        return
      end

      # Update without password if not provided
      if user_params[:password].blank?
        params_without_password = user_params.except(:password, :password_confirmation)
        success = @user.update(params_without_password)
      else
        success = @user.update(user_params)
      end

      if success
        redirect_to admin_users_path, notice: 'User was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      # Prevent self-deletion
      if @user == current_user
        redirect_to admin_users_path, alert: 'You cannot delete your own account.'
        return
      end

      # Prevent deletion of last super admin
      if @user.super_admin? && User.super_admins.count == 1
        redirect_to admin_users_path, alert: 'Cannot delete the last super admin.'
        return
      end

      @user.destroy!
      redirect_to admin_users_path, notice: 'User was successfully deleted.'
    end

    private

    def set_user
      @user = User.find(params[:id])
    end

    def user_params
      # Only super admins can set role
      if super_admin_signed_in?
        params.require(:user).permit(:email, :name, :password, :password_confirmation, :role)
      else
        params.require(:user).permit(:email, :name, :password, :password_confirmation)
      end
    end
  end
end