FactoryBot.define do
  factory :analytic do
    lead { nil }
    event_type { "MyString" }
    source { "MyString" }
    medium { "MyString" }
    campaign { "MyString" }
    metadata { "" }
  end
end
