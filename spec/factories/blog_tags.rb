FactoryBot.define do
  factory :blog_tag do
    sequence(:name) { |n| "Tag #{n}" }
    usage_count { 0 }

    trait :popular do
      usage_count { 50 }
    end
  end
end
