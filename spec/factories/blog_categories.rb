FactoryBot.define do
  factory :blog_category do
    sequence(:name) { |n| "Category #{n}" }
    description { "This is a category description" }
    parent { nil }
    post_count { 0 }

    trait :with_parent do
      association :parent, factory: :blog_category
    end

    trait :with_posts do
      post_count { 10 }
    end
  end
end
