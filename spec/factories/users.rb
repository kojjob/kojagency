FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
    sequence(:name) { |n| "User #{n}" }
    role { :user }

    trait :admin do
      role { :admin }
    end

    trait :confirmed do
      confirmed_at { 1.day.ago }
    end

    trait :with_blog_posts do
      after(:create) do |user|
        create_list(:blog_post, 3, author: user)
      end
    end

    trait :with_comments do
      after(:create) do |user|
        blog_post = create(:blog_post)
        create_list(:blog_comment, 2, user: user, blog_post: blog_post)
      end
    end
  end
end
