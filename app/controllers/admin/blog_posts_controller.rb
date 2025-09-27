module Admin
  class BlogPostsController < ApplicationController
    before_action :authenticate_admin_or_blog_author!
    before_action :set_post, only: [:show, :edit, :update, :destroy, :publish, :archive, :preview]
    before_action :authorize_post_access!, only: [:show, :edit, :update, :destroy, :publish, :archive, :preview]
    before_action :load_form_data, only: [:new, :edit]

    def index
      @posts = current_blog_author ? current_blog_author.blog_posts : BlogPost.all
      @posts = @posts.where(status: params[:status]) if params[:status].present?
      if params[:q].present?
        @posts = @posts.joins(:rich_text_content)
                       .where('title ILIKE :q OR action_text_rich_texts.body ILIKE :q', q: "%#{params[:q]}%")
      end
      @posts = @posts.order(created_at: :desc).page(params[:page]).per(20)
    end

    def show
    end

    def new
      @post = BlogPost.new
    end

    def create
      @post = BlogPost.new(post_params)

      # If current user is a blog author, set them as the author automatically
      if current_blog_author
        @post.author = current_blog_author
      else
        # Handle new author creation if needed (admin only)
        if params[:new_author_name].present? && params[:new_author_email].present?
          author = BlogAuthor.find_or_create_by(email: params[:new_author_email]) do |a|
            a.name = params[:new_author_name]
            a.bio = params[:new_author_bio] if params[:new_author_bio].present?
            a.title = params[:new_author_title] if params[:new_author_title].present?
            a.company = params[:new_author_company] if params[:new_author_company].present?
            a.location = params[:new_author_location] if params[:new_author_location].present?
            a.expertise = params[:new_author_expertise].split(',').map(&:strip) if params[:new_author_expertise].present?
            a.follower_count = params[:new_author_follower_count].to_i if params[:new_author_follower_count].present?
            a.verified = params[:new_author_verified] == '1'

            # Social media
            if a.social_media.nil?
              a.social_media = {}
            end
            a.social_media['twitter'] = params[:new_author_twitter] if params[:new_author_twitter].present?
            a.social_media['linkedin'] = params[:new_author_linkedin] if params[:new_author_linkedin].present?
            a.social_media['github'] = params[:new_author_github] if params[:new_author_github].present?
            a.social_media['website'] = params[:new_author_website] if params[:new_author_website].present?
          end
          @post.author = author
        else
          set_author_from_params
        end
      end

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
      # Handle new author creation if needed
      if params[:new_author_name].present? && params[:new_author_email].present?
        author = BlogAuthor.find_or_create_by(email: params[:new_author_email]) do |a|
          a.name = params[:new_author_name]
          a.bio = params[:new_author_bio] if params[:new_author_bio].present?
          a.title = params[:new_author_title] if params[:new_author_title].present?
          a.company = params[:new_author_company] if params[:new_author_company].present?
          a.location = params[:new_author_location] if params[:new_author_location].present?
          a.expertise = params[:new_author_expertise].split(',').map(&:strip) if params[:new_author_expertise].present?
          a.follower_count = params[:new_author_follower_count].to_i if params[:new_author_follower_count].present?
          a.verified = params[:new_author_verified] == '1'

          # Social media
          if a.social_media.nil?
            a.social_media = {}
          end
          a.social_media['twitter'] = params[:new_author_twitter] if params[:new_author_twitter].present?
          a.social_media['linkedin'] = params[:new_author_linkedin] if params[:new_author_linkedin].present?
          a.social_media['github'] = params[:new_author_github] if params[:new_author_github].present?
          a.social_media['website'] = params[:new_author_website] if params[:new_author_website].present?
        end
        @post.author = author
      else
        set_author_from_params
      end

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
        :hero_style, :content_layout,
        tag_ids: [], content_images: []
      )
    end

    def set_author_from_params
      if params[:blog_post][:author_id].present?
        author_type, author_id = params[:blog_post][:author_id].split('-')
        @post.author_type = author_type
        @post.author_id = author_id.to_i if author_id.present?
      else
        # Clear author if no author selected
        @post.author = nil
      end
    end

    def authenticate_admin_or_blog_author!
      unless admin_signed_in? || blog_author_signed_in?
        redirect_to root_path, alert: 'Access denied'
      end
    end

    def authorize_post_access!
      return if admin_current_user&.admin? # Admins can access any post

      # Blog authors can only access their own posts
      if current_blog_author && @post.author != current_blog_author
        redirect_to admin_blog_posts_path, alert: 'Not authorized to access this post'
      elsif !current_blog_author
        redirect_to root_path, alert: 'Not authorized'
      end
    end
  end
end