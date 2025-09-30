FactoryBot.define do
  factory :blog_post do
    association :author, factory: :blog_author
    association :category, factory: :blog_category

    sequence(:title) { |n| "Blog Post #{n}" }
    sequence(:slug) { |n| "blog-post-#{n}" }
    rich_content { "This is a comprehensive blog post with lots of content. " * 50 } # ~250 words
    excerpt { "This is an excerpt of the blog post." }
    status { "draft" }
    published_at { nil }
    featured { false }
    views_count { 0 }
    shares_count { 0 }
    reading_time { 1 }
    meta_title { "SEO Title" }
    meta_description { "This is a meta description for SEO purposes." }
    meta_keywords { "blog, post, keywords" }
    canonical_url { "https://example.com/blog/post" }
    country_code { "US" }
    region { "California" }
    city { "San Francisco" }
    latitude { 37.7749 }
    longitude { -122.4194 }

    trait :published do
      status { "published" }
      published_at { 1.day.ago }
    end

    trait :scheduled do
      status { "scheduled" }
      published_at { 1.day.from_now }
    end

    trait :archived do
      status { "archived" }
      published_at { 1.month.ago }
    end

    trait :featured do
      featured { true }
    end

    trait :with_high_engagement do
      views_count { 1000 }
      shares_count { 100 }
    end

    trait :with_user_author do
      transient do
        author_user { create(:user) }
      end
      author { author_user }
    end

    factory :user_blog_post, parent: :blog_post do
      transient do
        user_author { create(:user) }
      end

      author_id { user_author.id }
      author_type { 'User' }
      author { user_author }
    end
  end
end
