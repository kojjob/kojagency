xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0" do
  xml.channel do
    xml.title "Koj Agency Blog"
    xml.description "Latest insights on web development, mobile apps, data engineering, and digital transformation"
    xml.link blog_posts_url

    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.description post.excerpt || truncate(post.content, length: 300)
        xml.pubDate post.published_at&.rfc822
        xml.link blog_post_url(post)
        xml.guid blog_post_url(post)
        xml.author post.author.email if post.author.email.present?
        xml.category post.category.name if post.category
      end
    end
  end
end