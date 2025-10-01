module Admin
  class BlogCategoriesController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin
    before_action :set_category, only: [ :show, :edit, :update, :destroy ]

    def index
      @categories = BlogCategory.includes(:parent, :blog_posts)
                                .order(created_at: :desc)
                                .page(params[:page]).per(20)

      @stats = {
        total: BlogCategory.count,
        top_level: BlogCategory.top_level.count,
        with_posts: BlogCategory.with_posts.count
      }
    end

    def show
      @posts = @category.blog_posts.published.order(published_at: :desc).limit(10)
    end

    def new
      @category = BlogCategory.new
      @parent_categories = BlogCategory.top_level.order(:name)
    end

    def create
      @category = BlogCategory.new(category_params)

      if @category.save
        redirect_to admin_blog_category_path(@category), notice: "Category was successfully created."
      else
        @parent_categories = BlogCategory.top_level.order(:name)
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @parent_categories = BlogCategory.where.not(id: @category.id).top_level.order(:name)
    end

    def update
      if @category.update(category_params)
        redirect_to admin_blog_category_path(@category), notice: "Category was successfully updated."
      else
        @parent_categories = BlogCategory.where.not(id: @category.id).top_level.order(:name)
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @category.blog_posts.any?
        redirect_to admin_blog_categories_path, alert: "Cannot delete category with associated posts."
      else
        @category.destroy
        redirect_to admin_blog_categories_path, notice: "Category was successfully deleted."
      end
    end

    private

    def set_category
      @category = BlogCategory.friendly.find(params[:id])
    end

    def category_params
      params.require(:blog_category).permit(:name, :description, :parent_id)
    end
  end
end
