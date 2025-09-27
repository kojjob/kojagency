class User::BlogPostsController < ApplicationController
  before_action :authenticate_user!
  before_action :debug_user_state
  before_action :set_blog_post, only: [:show, :edit, :update, :destroy, :publish, :unpublish]
  before_action :ensure_owner, only: [:show, :edit, :update, :destroy, :publish, :unpublish]

  def index
    Rails.logger.debug "DEBUG: current_user = #{current_user.inspect}"
    Rails.logger.debug "DEBUG: user_signed_in? = #{user_signed_in?}"

    @blog_posts = current_user.blog_posts
                              .includes(:category, :tags)
                              .order(created_at: :desc)
                              .page(params[:page])
                              .per(10)
  end

  def show
    # @blog_post already set by before_action
  end

  def new
    @blog_post = current_user.blog_posts.build
    load_form_data
  end

  def create
    @blog_post = current_user.blog_posts.build(blog_post_params)

    if @blog_post.save
      redirect_to user_blog_post_path(@blog_post), notice: 'Blog post was successfully created.'
    else
      load_form_data
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_form_data
  end

  def update
    if @blog_post.update(blog_post_params)
      redirect_to user_blog_post_path(@blog_post), notice: 'Blog post was successfully updated.'
    else
      load_form_data
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @blog_post.destroy!
    redirect_to user_blog_posts_path, notice: 'Blog post was successfully deleted.'
  end

  def publish
    @blog_post.update!(status: :published, published_at: Time.current)
    redirect_to user_blog_post_path(@blog_post), notice: 'Blog post was published successfully.'
  end

  def unpublish
    @blog_post.update!(status: :draft, published_at: nil)
    redirect_to user_blog_post_path(@blog_post), notice: 'Blog post was unpublished successfully.'
  end

  private

  def debug_user_state
    Rails.logger.debug "DEBUG debug_user_state: user_signed_in? = #{user_signed_in?}"
    Rails.logger.debug "DEBUG debug_user_state: current_user = #{current_user.inspect}"
    Rails.logger.debug "DEBUG debug_user_state: session = #{session.inspect}"
    Rails.logger.debug "DEBUG debug_user_state: request format = #{request.format}"
    Rails.logger.debug "DEBUG debug_user_state: action = #{action_name}"
  end

  def set_blog_post
    @blog_post = BlogPost.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to user_blog_posts_path, alert: 'Blog post not found.'
  end

  def ensure_owner
    Rails.logger.debug "DEBUG ensure_owner: @blog_post = #{@blog_post.inspect}"
    Rails.logger.debug "DEBUG ensure_owner: current_user = #{current_user.inspect}"
    return unless @blog_post # Skip if no blog post is set

    unless @blog_post.author == current_user
      Rails.logger.debug "DEBUG ensure_owner: Rendering forbidden because author mismatch"
      render plain: 'Forbidden', status: :forbidden
    end
  end

  def blog_post_params
    params.require(:blog_post).permit(
      :title, :slug, :content, :excerpt, :meta_title, :meta_description, :meta_keywords,
      :canonical_url, :status, :reading_time, :featured_image, :category_id,
      tag_ids: []
    )
  end

  def load_form_data
    @categories = BlogCategory.order(:name)
    @tags = BlogTag.order(:name)
  end
end