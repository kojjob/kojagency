FactoryBot.define do
  factory :project do
    sequence(:title) { |n| "Project #{n}" }
    description { "A comprehensive description of the project that demonstrates our expertise in delivering high-quality solutions. This project showcases our technical capabilities and client-focused approach." }
    client_name { "Tech Corp" }
    project_url { "https://example.com/project" }
    github_url { "https://github.com/company/project" }
    completion_date { 6.months.ago }
    duration_months { 6 }
    team_size { 4 }
    status { :published }
    featured { false }

    trait :draft do
      status { :draft }
    end

    trait :published do
      status { :published }
    end

    trait :archived do
      status { :archived }
    end

    trait :featured do
      featured { true }
      status { :published }
    end

    trait :recent do
      completion_date { 1.month.ago }
    end

    trait :old do
      completion_date { 2.years.ago }
    end

    trait :minimal do
      project_url { nil }
      github_url { nil }
      duration_months { nil }
      team_size { nil }
    end
  end
end
