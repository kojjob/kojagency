FactoryBot.define do
  factory :blog_author do
    sequence(:name) { |n| "Author #{n}" }
    sequence(:email) { |n| "author#{n}@example.com" }
    bio { "An experienced writer with expertise in technology and business." }
    website { "https://example.com" }
    social_media do
      {
        twitter: "https://twitter.com/author",
        linkedin: "https://linkedin.com/in/author",
        github: "https://github.com/author"
      }
    end
  end
end
