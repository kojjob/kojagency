xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  @posts.each do |post|
    xml.url do
      xml.loc blog_post_url(post)
      xml.lastmod post.updated_at.iso8601
      xml.changefreq "weekly"
      xml.priority "0.7"
    end
  end
end
