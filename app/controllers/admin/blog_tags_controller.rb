module Admin
  class BlogTagsController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin
    before_action :set_tag, only: [:show, :edit, :update, :destroy]

    def index
      @tags = BlogTag.includes(:posts)
                    .order(usage_count: :desc, name: :asc)
                    .page(params[:page]).per(25)

      @stats = {
        total: BlogTag.count,
        used: BlogTag.used.count,
        unused: BlogTag.where(usage_count: 0).count
      }
    end

    def show
      @posts = @tag.posts.published.order(published_at: :desc).limit(10)
    end

    def new
      @tag = BlogTag.new
    end

    def create
      @tag = BlogTag.new(tag_params)

      if @tag.save
        redirect_to admin_blog_tag_path(@tag), notice: 'Tag was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @tag.update(tag_params)
        redirect_to admin_blog_tag_path(@tag), notice: 'Tag was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      if @tag.posts.any?
        redirect_to admin_blog_tags_path, alert: 'Cannot delete tag with associated posts.'
      else
        @tag.destroy
        redirect_to admin_blog_tags_path, notice: 'Tag was successfully deleted.'
      end
    end

    private

    def set_tag
      @tag = BlogTag.friendly.find(params[:id])
    end

    def tag_params
      params.require(:blog_tag).permit(:name, :description)
    end
  end
end