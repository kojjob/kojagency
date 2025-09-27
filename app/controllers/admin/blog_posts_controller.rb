module Admin
  class BlogPostsController < ApplicationController
    before_action :authenticate_admin!
    before_action :require_admin
    before_action :set_post, only: [:show, :edit, :update, :destroy, :publish, :archive, :preview]
    before_action :load_form_data, only: [:new, :edit]

    def index
      @posts = BlogPost.all
      @posts = @posts.where(status: params[:status]) if params[:status].present?
      @posts = @posts.where('title ILIKE :q OR content ILIKE :q', q: "%#{params[:q]}%") if params[:q].present?
      @posts = @posts.order(created_at: :desc).page(params[:page]).per(20)
    end

    def show
    end

    def new
      @post = BlogPost.new
    end

    def create
      @post = BlogPost.new(post_params)

      if @post.save
        redirect_to admin_blog_post_path(@post), notice: 'Blog post was successfully created.'
      else
        load_form_data
        render :new
      end
    end

    def edit
    end

    def update
      if @post.update(post_params)
        redirect_to admin_blog_post_path(@post), notice: 'Blog post was successfully updated.'
      else
        load_form_data
        render :edit
      end
    end

    def destroy
      @post.destroy
      redirect_to admin_blog_posts_path, notice: 'Blog post was successfully deleted.'
    end

    def publish
      @post.publish!
      redirect_to admin_blog_posts_path, notice: 'Blog post was successfully published.'
    end

    def archive
      @post.archive!
      redirect_to admin_blog_posts_path, notice: 'Blog post was successfully archived.'
    end

    def preview
      render layout: false
    end

    private

    def set_post
      @post = BlogPost.friendly.find(params[:id])
    end

    def load_form_data
      @authors = BlogAuthor.order(:name)
      @categories = BlogCategory.order(:name)
      @tags = BlogTag.order(:name)
    end

    def post_params
      params.require(:blog_post).permit(
        :title, :content, :excerpt, :author_id, :category_id, :status,
        :featured_image, :published_at, :featured,
        :meta_title, :meta_description, :meta_keywords,
        :canonical_url, :og_title, :og_description, :og_image_url,
        :twitter_card, :twitter_title, :twitter_description, :twitter_image_url,
        :country_code, :region, :city, :latitude, :longitude,
        tag_ids: []
      )
    end

    def require_admin
      unless admin_current_user&.admin?
        redirect_to root_path, alert: 'Not authorized'
      end
    end
  end
end