FactoryBot.define do
  factory :lead do
    first_name { "Alex" }
    last_name { "Johnson" }
    email { "alex.johnson@techcorp.com" }
    phone { "+1-555-123-4567" }
    company { "TechCorp Analytics" }
    website { "https://techcorp-analytics.com" }
    project_type { "data_engineering" }
    budget { "100k_250k" }
    timeline { "3_months" }
    project_description { "We need to build a comprehensive data pipeline to process our customer analytics data from multiple sources including Salesforce, Google Analytics, and our proprietary mobile app." }
    preferred_contact_method { "email" }
    source { "website" }
    lead_status { "pending" }

    # Factory for high priority lead
    trait :high_priority do
      budget { "250k_plus" }
      timeline { "asap" }
      project_description { "Urgent enterprise data pipeline project requiring immediate attention. We have regulatory deadlines and need a proven solution with demonstrated success in similar implementations." }
      website { "https://fortune500company.com" }
      email { "cto@fortune500company.com" }
    end

    # Factory for medium priority lead
    trait :medium_priority do
      budget { "50k_100k" }
      timeline { "6_months" }
      project_description { "Looking to modernize our data infrastructure and implement better analytics." }
    end

    # Factory for low priority lead
    trait :low_priority do
      budget { "under_10k" }
      timeline { "flexible" }
      project_description { "Basic website needed." }
      email { "personal@gmail.com" }
      website { nil }
    end

    # Factory for contacted lead
    trait :contacted do
      lead_status { "contacted" }
      contacted_at { 2.hours.ago }
    end

    # Factory for qualified lead
    trait :qualified do
      lead_status { "qualified" }
      qualified_at { 1.day.ago }
      contacted_at { 2.days.ago }
    end

    # Factory with all project types
    trait :web_development do
      project_type { "web_development" }
      project_description { "We need a modern web application with user authentication and real-time features." }
    end

    trait :mobile_development do
      project_type { "mobile_development" }
      project_description { "Looking to develop native iOS and Android applications for our service platform." }
    end

    trait :analytics_platform do
      project_type { "analytics_platform" }
      project_description { "Need a comprehensive business intelligence dashboard with real-time data visualization." }
    end

    trait :technical_consulting do
      project_type { "technical_consulting" }
      project_description { "Seeking architecture review and technology strategy consultation for our growing startup." }
    end

    trait :other do
      project_type { "other" }
      project_description { "Custom solution for unique business requirements in the fintech space." }
    end
  end
end
