# Blog Seed Data

puts "Creating blog authors..."
authors = [
  {
    name: "John Smith",
    email: "john@kojagency.com",
    bio: "Chief Technology Officer at Koj Agency with over 15 years of experience in software development and digital transformation.",
    website: "https://johnsmith.dev",
    social_media: { twitter: "@johnsmith", linkedin: "johnsmith", github: "johnsmith" }
  },
  {
    name: "Sarah Johnson",
    email: "sarah@kojagency.com",
    bio: "Digital Marketing Strategist specializing in growth marketing and content strategy for B2B SaaS companies.",
    website: "https://sarahjohnson.marketing",
    social_media: { twitter: "@sarahj", linkedin: "sarahjohnson" }
  },
  {
    name: "Mike Chen",
    email: "mike@kojagency.com",
    bio: "Senior Developer and Data Engineer focused on building scalable data pipelines and analytics platforms.",
    website: nil,
    social_media: { github: "mikechen", linkedin: "mikechen" }
  }
].map { |attrs| BlogAuthor.create!(attrs) }

puts "Creating blog categories..."
categories = {
  web_dev: BlogCategory.create!(
    name: "Web Development",
    description: "Latest trends and best practices in web development",
    parent: nil
  ),
  data_engineering: BlogCategory.create!(
    name: "Data Engineering",
    description: "Building robust data pipelines and analytics platforms",
    parent: nil
  ),
  digital_marketing: BlogCategory.create!(
    name: "Digital Marketing",
    description: "Growth strategies and marketing insights",
    parent: nil
  ),
  case_studies: BlogCategory.create!(
    name: "Case Studies",
    description: "Success stories from our client projects",
    parent: nil
  ),
  tutorials: BlogCategory.create!(
    name: "Tutorials",
    description: "Step-by-step guides and how-to articles",
    parent: nil
  )
}

# Create subcategories
BlogCategory.create!(name: "Ruby on Rails", description: "Rails development tips", parent: categories[:web_dev])
BlogCategory.create!(name: "React", description: "Modern React development", parent: categories[:web_dev])
BlogCategory.create!(name: "SEO", description: "Search engine optimization", parent: categories[:digital_marketing])
BlogCategory.create!(name: "Content Marketing", description: "Content strategy and creation", parent: categories[:digital_marketing])

puts "Creating blog tags..."
tags = [
  "Ruby", "Rails", "JavaScript", "React", "Vue.js", "Python", "Data Science",
  "Machine Learning", "AWS", "DevOps", "Docker", "Kubernetes", "PostgreSQL",
  "Redis", "SEO", "Content Strategy", "Growth Hacking", "Analytics", "A/B Testing",
  "Performance", "Security", "Best Practices", "Tutorial", "Case Study"
].map { |name| BlogTag.create!(name: name) }

puts "Creating blog posts..."

# Sample blog posts with rich content
posts_data = [
  {
    title: "Building Scalable Web Applications with Ruby on Rails",
    content: "In this comprehensive guide, we'll explore the best practices for building scalable web applications using Ruby on Rails. From database optimization to caching strategies, we'll cover everything you need to know to handle millions of users.",
    excerpt: "Learn how to build web applications that can scale from startup to enterprise using Ruby on Rails.",
    author: authors[0],
    category: categories[:web_dev],
    tags: tags.select { |t| [ "Ruby", "Rails", "Performance", "Best Practices" ].include?(t.name) },
    status: "published",
    published_at: 7.days.ago,
    views_count: 1250,
    shares_count: 45,
    meta_title: "Scalable Rails Apps - Complete Guide | Koj Agency",
    meta_description: "Comprehensive guide to building scalable Ruby on Rails applications with performance optimization tips.",
    meta_keywords: "rails, scalability, performance, web development"
  },
  {
    title: "Modern Data Pipeline Architecture: A Comprehensive Guide",
    content: "Data pipelines are the backbone of modern data-driven organizations. This article explores various architectural patterns, tools, and best practices for building robust, scalable data pipelines that can handle petabytes of data.",
    excerpt: "Explore modern data pipeline architectures and learn how to build robust ETL/ELT processes.",
    author: authors[2],
    category: categories[:data_engineering],
    tags: tags.select { |t| [ "Python", "Data Science", "AWS", "Best Practices" ].include?(t.name) },
    status: "published",
    published_at: 5.days.ago,
    views_count: 890,
    shares_count: 32
  },
  {
    title: "The Complete Guide to B2B Content Marketing in 2024",
    content: "Content marketing continues to evolve rapidly. In this guide, we share insights from successful B2B content marketing campaigns and provide actionable strategies for creating content that drives leads and conversions.",
    excerpt: "Master B2B content marketing with proven strategies that drive leads and conversions.",
    author: authors[1],
    category: categories[:digital_marketing],
    tags: tags.select { |t| [ "Content Strategy", "SEO", "Growth Hacking", "Analytics" ].include?(t.name) },
    status: "published",
    published_at: 3.days.ago,
    views_count: 2100,
    shares_count: 78
  },
  {
    title: "Implementing Real-time Features with Action Cable and React",
    content: "Learn how to build real-time features in your Rails application using Action Cable and React. We'll create a live chat application with typing indicators, online presence, and message delivery receipts.",
    excerpt: "Build real-time features with Rails Action Cable and React for engaging user experiences.",
    author: authors[0],
    category: categories[:tutorials],
    tags: tags.select { |t| [ "Ruby", "Rails", "React", "JavaScript", "Tutorial" ].include?(t.name) },
    status: "published",
    published_at: 1.day.ago,
    views_count: 567,
    shares_count: 23
  },
  {
    title: "Case Study: Scaling an E-commerce Platform from 0 to $10M ARR",
    content: "Discover how we helped an e-commerce startup scale their platform to handle 100,000+ daily active users and process over $10M in annual revenue. This case study covers the technical challenges, solutions implemented, and results achieved.",
    excerpt: "How we scaled an e-commerce platform to $10M ARR with strategic technical improvements.",
    author: authors[2],
    category: categories[:case_studies],
    tags: tags.select { |t| [ "Case Study", "Performance", "AWS", "DevOps" ].include?(t.name) },
    status: "published",
    published_at: 10.days.ago,
    views_count: 3450,
    shares_count: 120,
    featured: true
  },
  {
    title: "Optimizing PostgreSQL for High-Traffic Applications",
    content: "Database performance is critical for application success. This article covers advanced PostgreSQL optimization techniques including query optimization, indexing strategies, connection pooling, and partitioning.",
    excerpt: "Advanced PostgreSQL optimization techniques for high-performance applications.",
    author: authors[0],
    category: categories[:web_dev],
    tags: tags.select { |t| [ "PostgreSQL", "Performance", "Best Practices" ].include?(t.name) },
    status: "published",
    published_at: 14.days.ago,
    views_count: 1876,
    shares_count: 67
  },
  {
    title: "Building a Modern CI/CD Pipeline with GitHub Actions",
    content: "Continuous Integration and Deployment are essential for modern software development. Learn how to set up a comprehensive CI/CD pipeline using GitHub Actions, including automated testing, code quality checks, and deployment strategies.",
    excerpt: "Set up a comprehensive CI/CD pipeline with GitHub Actions for automated deployment.",
    author: authors[2],
    category: categories[:tutorials],
    tags: tags.select { |t| [ "DevOps", "Best Practices", "Tutorial" ].include?(t.name) },
    status: "published",
    published_at: 8.days.ago,
    views_count: 923,
    shares_count: 41
  },
  {
    title: "SEO in 2024: What's Changed and What Still Matters",
    content: "Search engine optimization continues to evolve with AI and machine learning. This comprehensive guide covers the latest SEO trends, Google algorithm updates, and proven strategies for improving organic search visibility.",
    excerpt: "Stay ahead with the latest SEO trends and strategies for 2024.",
    author: authors[1],
    category: categories[:digital_marketing],
    tags: tags.select { |t| [ "SEO", "Content Strategy", "Analytics" ].include?(t.name) },
    status: "published",
    published_at: 4.days.ago,
    views_count: 2890,
    shares_count: 95
  },
  {
    title: "Kubernetes Best Practices for Production Deployments",
    content: "Running Kubernetes in production requires careful planning and implementation. This guide covers security hardening, resource management, monitoring, and disaster recovery strategies for production Kubernetes clusters.",
    excerpt: "Essential Kubernetes best practices for secure and reliable production deployments.",
    author: authors[2],
    category: categories[:web_dev],
    tags: tags.select { |t| [ "Kubernetes", "Docker", "DevOps", "Security", "Best Practices" ].include?(t.name) },
    status: "published",
    published_at: 12.days.ago,
    views_count: 1567,
    shares_count: 89
  },
  {
    title: "A/B Testing: Statistical Significance and Common Pitfalls",
    content: "A/B testing is crucial for data-driven decision making. Learn about statistical significance, sample size calculations, common mistakes to avoid, and how to design experiments that yield actionable insights.",
    excerpt: "Master A/B testing with proper statistical methods and avoid common pitfalls.",
    author: authors[1],
    category: categories[:digital_marketing],
    tags: tags.select { |t| [ "A/B Testing", "Analytics", "Growth Hacking" ].include?(t.name) },
    status: "published",
    published_at: 6.days.ago,
    views_count: 1234,
    shares_count: 52
  }
]

posts_data.each do |post_data|
  tags = post_data.delete(:tags)
  post = BlogPost.create!(post_data)

  # Add tags
  tags.each do |tag|
    BlogPostTag.create!(blog_post: post, blog_tag: tag)
  end

  # Update tag usage counts
  tags.each(&:update_usage_count)
end

# Create some draft posts
3.times do |i|
  BlogPost.create!(
    title: "Draft Post #{i + 1}",
    content: "This is a draft post that hasn't been published yet.",
    excerpt: "Draft post excerpt",
    author: authors.sample,
    category: categories.values.sample,
    status: "draft"
  )
end

# Create a scheduled post
BlogPost.create!(
  title: "Upcoming: The Future of Web Development",
  content: "An exciting look at what's coming next in web development...",
  excerpt: "Exploring the future trends in web development",
  author: authors[0],
  category: categories[:web_dev],
  status: "scheduled",
  published_at: 3.days.from_now
)

# Create blog subscriptions
puts "Creating blog subscriptions..."
emails = [
  "subscriber1@example.com",
  "subscriber2@example.com",
  "marketing@company.com",
  "developer@startup.com"
]

emails.each do |email|
  BlogSubscription.create!(email: email, active: true)
end

# Add related posts
puts "Creating related post connections..."
posts = BlogPost.published
posts.each do |post|
  # Add 2-3 related posts
  related = posts.where.not(id: post.id).sample(rand(2..3))
  related.each do |related_post|
    BlogRelatedPost.create!(
      blog_post: post,
      related_post: related_post
    ) rescue nil # Ignore if already exists
  end
end

puts "Blog seed data created successfully!"
puts "  - #{BlogAuthor.count} authors"
puts "  - #{BlogCategory.count} categories"
puts "  - #{BlogTag.count} tags"
puts "  - #{BlogPost.count} posts (#{BlogPost.published.count} published)"
puts "  - #{BlogSubscription.count} subscriptions"
