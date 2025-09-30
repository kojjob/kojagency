class Blog::CommentsController < ApplicationController
  before_action :find_blog_post
  before_action :find_comment, only: [ :destroy ]

  def create
    @comment = @blog_post.blog_comments.build(comment_params)

    if verify_recaptcha_or_development? && @comment.save
      # Auto-approve comments in development
      @comment.approve! if Rails.env.development?

      respond_to do |format|
        format.html { redirect_to blog_post_path(@blog_post), notice: comment_notice_message }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_to blog_post_path(@blog_post), alert: "Error submitting comment. Please try again." }
        format.turbo_stream { render turbo_stream: turbo_stream.update("comment-form-errors", partial: "blog/comments/errors", locals: { comment: @comment }) }
      end
    end
  end

  def destroy
    if admin_signed_in?
      @comment.destroy
      respond_to do |format|
        format.html { redirect_to blog_post_path(@blog_post), notice: "Comment deleted successfully." }
        format.turbo_stream
      end
    else
      redirect_to blog_post_path(@blog_post), alert: "You are not authorized to delete this comment."
    end
  end

  private

  def find_blog_post
    @blog_post = BlogPost.friendly.find(params[:blog_post_id])
  end

  def find_comment
    @comment = @blog_post.blog_comments.find(params[:id])
  end

  def comment_params
    params.require(:blog_comment).permit(:author_name, :author_email, :author_website, :content, :parent_id)
  end

  def comment_notice_message
    if @comment.approved?
      "Thank you for your comment!"
    else
      "Your comment has been submitted and is awaiting moderation."
    end
  end

  def verify_recaptcha_or_development?
    # For now, always return true. In production, implement recaptcha
    true
  end

  def admin_signed_in?
    # Implement your admin authentication logic here
    # For now, we'll return false
    false
  end
end
