module Blog
  class PostsController < ApplicationController
    layout "blog"
    before_action :set_post, only: [ :show ]
    before_action :set_meta_tags_for_index, only: [ :index ]

    rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found

    def index
      @posts = BlogPost.published.recent
      @posts = filter_by_category if params[:category].present?
      @posts = filter_by_tag if params[:tag].present?
      @posts = search_posts if params[:q].present?
      @posts = @posts.page(params[:page]).per(12)

      # For the new design
      @featured_post = BlogPost.published.featured.first
      @tags = BlogTag.joins(:blog_post_tags)
                     .joins("JOIN blog_posts ON blog_post_tags.blog_post_id = blog_posts.id")
                     .where("blog_posts.status = 'published'")
                     .group("blog_tags.id, blog_tags.name, blog_tags.slug")
                     .order("COUNT(blog_post_tags.id) DESC")
                     .limit(6)
      @categories = BlogCategory.joins(:blog_posts)
                                .where("blog_posts.status = 'published'")
                                .group("blog_categories.id")
                                .order("COUNT(blog_posts.id) DESC")
      @recent_posts = BlogPost.published.recent.limit(5)

      respond_to do |format|
        format.html
        format.json { render json: @posts }
      end
    end

    def show
      @post.increment_views!
      @related_posts = BlogPost.published
                              .where(category: @post.category)
                              .where.not(id: @post.id)
                              .limit(4)

      set_meta_tags_for_post
    end

    def feed
      @posts = BlogPost.published.recent.limit(20)

      respond_to do |format|
        format.rss { render layout: false }
      end
    end

    def sitemap
      @posts = BlogPost.for_sitemap

      respond_to do |format|
        format.xml { render layout: false }
      end
    end

    def subscribe
      @subscription = BlogSubscription.new(email: params[:email])

      if @subscription.save
        render json: { status: "success", message: "Successfully subscribed!" }
      else
        if @subscription.errors[:email].include?("has already been taken")
          render json: { status: "error", message: "Email already subscribed" }, status: :unprocessable_entity
        else
          render json: { status: "error", message: @subscription.errors.full_messages.join(", ") }, status: :unprocessable_entity
        end
      end
    end

    private

    def set_post
      @post = BlogPost.published.friendly.find(params[:id])
    end

    def filter_by_category
      category = BlogCategory.friendly.find(params[:category])
      @posts.where(category: category)
    end

    def filter_by_tag
      tag = BlogTag.friendly.find(params[:tag])
      @posts.joins(:blog_post_tags).where(blog_post_tags: { blog_tag_id: tag.id })
    end

    def search_posts
      @posts.where("title ILIKE :q OR content ILIKE :q", q: "%#{params[:q]}%")
    end

    def set_meta_tags_for_index
      @meta_tags = {
        title: "Blog - Koj Agency",
        description: "Latest insights on web development, mobile apps, data engineering, and digital transformation",
        keywords: "blog, technology, web development, mobile apps, data engineering",
        og: {
          title: "Blog - Koj Agency",
          description: "Latest insights on web development, mobile apps, data engineering, and digital transformation",
          type: "website",
          url: request.original_url
        }
      }
    end

    def set_meta_tags_for_post
      @meta_tags = {
        title: @post.seo_title,
        description: @post.seo_description,
        keywords: @post.tags.pluck(:name).join(", "),
        og: {
          title: @post.seo_title,
          description: @post.seo_description,
          type: "article",
          url: request.original_url,
          article: {
            published_time: @post.published_at&.iso8601,
            modified_time: @post.updated_at.iso8601,
            author: @post.author&.name,
            section: @post.category&.name
          }
        }
      }
    end

    def handle_record_not_found
      redirect_to blog_posts_path, alert: "Blog post not found."
    end
  end
end
