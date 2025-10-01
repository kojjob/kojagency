FactoryBot.define do
  factory :service do
    sequence(:name) { |n| "Service #{n}" }
    description { 'A comprehensive service offering that delivers exceptional value to our clients through expert execution and innovative solutions.' }
    icon_class { 'fas fa-cog' }
    features { "Feature 1: Expert team\nFeature 2: Scalable solutions\nFeature 3: 24/7 support" }

    trait :web_development do
      name { 'Web Development' }
      description { 'Custom web applications built with modern frameworks and best practices for scalability and performance.' }
      icon_class { 'fas fa-globe' }
      features { "Modern frameworks (Rails, React, Vue)\nResponsive design\nAPI development\nDatabase optimization\nSecurity best practices" }
    end

    trait :mobile_development do
      name { 'Mobile Development' }
      description { 'Native and cross-platform mobile applications for iOS and Android with seamless user experiences.' }
      icon_class { 'fas fa-mobile-alt' }
      features { "Native iOS and Android\nCross-platform development\nPush notifications\nOffline support\nApp Store submission" }
    end

    trait :data_engineering do
      name { 'Data Engineering' }
      description { 'Building robust data pipelines, ETL processes, and data warehouses for scalable data infrastructure.' }
      icon_class { 'fas fa-database' }
      features { "Data pipeline design\nETL processes\nData warehousing\nReal-time processing\nData quality monitoring" }
    end

    trait :analytics_platforms do
      name { 'Analytics Platforms' }
      description { 'Custom analytics and business intelligence solutions with interactive dashboards and reporting.' }
      icon_class { 'fas fa-chart-line' }
      features { "Custom dashboards\nReal-time reporting\nData visualization\nPredictive analytics\nBI integration" }
    end

    trait :technical_consulting do
      name { 'Technical Consulting' }
      description { 'Expert guidance on technology strategy, architecture design, and best practices implementation.' }
      icon_class { 'fas fa-lightbulb' }
      features { "Architecture review\nTechnology selection\nPerformance optimization\nSecurity audit\nTeam training" }
    end
  end
end
