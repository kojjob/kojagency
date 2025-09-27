module Blog
  class TagsController < ApplicationController
    layout 'blog'
    before_action :set_tag, only: [:show]

    def index
      @tags = BlogTag.order(usage_count: :desc).limit(50)

      respond_to do |format|
        format.html
        format.json { render json: @tags.map { |t| { id: t.id, name: t.name, slug: t.slug, count: t.usage_count } } }
      end
    end

    def show
      @tag.increment!(:usage_count)

      @posts = BlogPost.published
                      .joins(:blog_post_tags)
                      .where(blog_post_tags: { blog_tag_id: @tag.id })
                      .recent
                      .page(params[:page]).per(12)

      @meta_tags = {
        title: "Posts tagged with #{@tag.name}",
        description: "Browse all blog posts tagged with #{@tag.name}",
        keywords: @tag.name
      }
    end

    def cloud
      tags = BlogTag.order(usage_count: :desc).limit(30)

      # Calculate weight for tag cloud visualization
      max_count = tags.maximum(:usage_count) || 1
      min_count = tags.minimum(:usage_count) || 0
      range = max_count - min_count
      range = 1 if range == 0

      @tag_cloud = tags.map do |tag|
        weight = ((tag.usage_count - min_count).to_f / range * 4 + 1).round
        tag.define_singleton_method(:weight) { weight }
        tag
      end

      respond_to do |format|
        format.html
        format.json do
          render json: @tag_cloud.map { |t|
            {
              name: t.name,
              weight: t.weight,
              url: blog_tag_path(t),
              count: t.usage_count
            }
          }
        end
      end
    end

    private

    def set_tag
      @tag = BlogTag.friendly.find(params[:id])
    end
  end
end