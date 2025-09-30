class Admin::BlogCommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_comment, only: [ :show, :approve, :reject, :destroy ]
  layout "admin"

  def index
    @comments = BlogComment.includes(:blog_post, :parent, :replies).order(created_at: :desc)

    # Apply filters
    if params[:q].present?
      search_term = "%#{params[:q]}%"
      @comments = @comments.where(
        "author_name ILIKE ? OR author_email ILIKE ? OR content ILIKE ?",
        search_term, search_term, search_term
      )
    end

    @comments = @comments.where(status: params[:status]) if params[:status].present?
    @comments = @comments.where(blog_post_id: params[:post_id]) if params[:post_id].present?

    # Pagination (if using pagy gem)
    # @pagy, @comments = pagy(@comments, items: 20)
  end

  def show
    # @comment is set by before_action
  end

  def approve
    if @comment.update(status: :approved)
      redirect_to admin_blog_comments_path, notice: "Comment approved successfully."
    else
      redirect_to admin_blog_comments_path, alert: "Failed to approve comment."
    end
  end

  def reject
    if @comment.update(status: :rejected)
      redirect_to admin_blog_comments_path, notice: "Comment rejected."
    else
      redirect_to admin_blog_comments_path, alert: "Failed to reject comment."
    end
  end

  def destroy
    if @comment.destroy
      redirect_to admin_blog_comments_path, notice: "Comment deleted successfully."
    else
      redirect_to admin_blog_comments_path, alert: "Failed to delete comment."
    end
  end

  private

  def set_comment
    @comment = BlogComment.find(params[:id])
  end
end
