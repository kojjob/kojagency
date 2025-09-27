module Blog
  class AuthorsController < ApplicationController
    layout 'blog'
    before_action :set_author, only: [:show]

    def index
      @authors = BlogAuthor.includes(:blog_posts).order(:name)

      # Add posts count to each author
      @authors = @authors.map do |author|
        author.define_singleton_method(:posts_count) do
          blog_posts.published.count
        end
        author
      end
    end

    def show
      @posts = @author.blog_posts.published.recent.page(params[:page]).per(12)

      @meta_tags = {
        title: "#{@author.name} - Author",
        description: @author.bio || "Browse blog posts by #{@author.name}",
        keywords: @author.name
      }
    end

    private

    def set_author
      @author = BlogAuthor.friendly.find(params[:id])
    end
  end
end