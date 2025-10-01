module Blog
  class CategoriesController < ApplicationController
    layout "blog"
    before_action :set_category, only: [ :show ]

    def index
      @categories = BlogCategory.includes(:blog_posts)
                                .order(:name)

      # Add posts count to each category
      @categories = @categories.map do |category|
        category.define_singleton_method(:posts_count) do
          blog_posts.published.count
        end
        category
      end
    end

    def show
      @posts = @category.blog_posts.published.recent.page(params[:page]).per(12)

      @meta_tags = {
        title: "#{@category.name} - Blog",
        description: @category.description || "Browse blog posts in the #{@category.name} category",
        keywords: @category.name
      }
    end

    private

    def set_category
      @category = BlogCategory.friendly.find(params[:id])
    end
  end
end
