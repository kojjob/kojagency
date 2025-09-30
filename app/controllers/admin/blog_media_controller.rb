module Admin
  class BlogMediaController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin
    before_action :set_media, only: [:show, :edit, :update, :destroy]

    def index
      @media_items = BlogMedia.includes(:posts)
                              .order(created_at: :desc)

      # Filter by media type
      @media_items = @media_items.where(media_type: params[:type]) if params[:type].present?

      @media_items = @media_items.page(params[:page]).per(24)

      @stats = {
        total: BlogMedia.count,
        images: BlogMedia.images.count,
        videos: BlogMedia.videos.count,
        audio: BlogMedia.audio.count,
        documents: BlogMedia.documents.count
      }
    end

    def show
      @posts = @media.posts.published.order(published_at: :desc).limit(10)
    end

    def new
      @media = BlogMedia.new
    end

    def create
      @media = BlogMedia.new(media_params)

      if @media.save
        redirect_to admin_blog_medium_path(@media), notice: 'Media was successfully uploaded.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @media.update(media_params)
        redirect_to admin_blog_medium_path(@media), notice: 'Media was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @media.destroy
      redirect_to admin_blog_media_index_path, notice: 'Media was successfully deleted.'
    end

    private

    def set_media
      @media = BlogMedia.find(params[:id])
    end

    def media_params
      params.require(:blog_media).permit(:title, :description, :alt_text, :media_type, :file, :metadata)
    end
  end
end