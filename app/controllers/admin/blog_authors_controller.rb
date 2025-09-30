module Admin
  class BlogAuthorsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin
    before_action :set_author, only: [ :show, :edit, :update, :destroy ]

    def index
      @authors = BlogAuthor.includes(:blog_posts)
                          .order(created_at: :desc)
                          .page(params[:page]).per(20)

      @stats = {
        total: BlogAuthor.count,
        verified: BlogAuthor.where(verified: true).count,
        with_posts: BlogAuthor.joins(:blog_posts).distinct.count
      }
    end

    def show
      @posts = @author.blog_posts.order(published_at: :desc).limit(10)
    end

    def new
      @author = BlogAuthor.new
    end

    def create
      @author = BlogAuthor.new(author_params)

      if @author.save
        redirect_to admin_blog_author_path(@author), notice: "Author was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @author.update(author_params)
        redirect_to admin_blog_author_path(@author), notice: "Author was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @author.blog_posts.any?
        redirect_to admin_blog_authors_path, alert: "Cannot delete author with associated posts."
      else
        @author.destroy
        redirect_to admin_blog_authors_path, notice: "Author was successfully deleted."
      end
    end

    private

    def set_author
      @author = BlogAuthor.friendly.find(params[:id])
    end

    def author_params
      params.require(:blog_author).permit(
        :name, :email, :bio, :title, :company, :website,
        :verified, :avatar, social_media: [ :twitter, :linkedin, :github ]
      )
    end
  end
end
