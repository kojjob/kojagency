FactoryBot.define do
  factory :blog_subscription do
    sequence(:email) { |n| "subscriber#{n}@example.com" }
    active { true }
    confirmed_at { 1.day.ago }

    trait :unconfirmed do
      confirmed_at { nil }
    end

    trait :inactive do
      active { false }
    end
  end
end
