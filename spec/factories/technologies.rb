FactoryBot.define do
  factory :technology do
    sequence(:name) { |n| "Technology #{n}" }
    category { 'Backend' }
    description { 'A powerful technology for building modern applications.' }
    icon_class { 'fab fa-code' }

    trait :frontend do
      category { 'Frontend' }
      icon_class { 'fab fa-react' }
    end

    trait :backend do
      category { 'Backend' }
      icon_class { 'fab fa-node-js' }
    end

    trait :database do
      category { 'Database' }
      icon_class { 'fas fa-database' }
    end

    trait :devops do
      category { 'DevOps' }
      icon_class { 'fab fa-docker' }
    end
  end
end