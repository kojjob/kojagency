# db/migrate/001_create_clients.rb
class CreateClients < ActiveRecord::Migration[8.0]
  def change
    create_table :clients do |t|
      t.string :name, null: false, limit: 100
      t.string :industry, null: false
      t.integer :company_size, null: false, default: 0
      t.string :website
      t.string :logo
      t.text :description
      t.string :location
      t.integer :founded_year
      
      t.timestamps
    end
    
    add_index :clients, :industry
    add_index :clients, :company_size
  end
end

# db/migrate/002_create_services.rb
class CreateServices < ActiveRecord::Migration[8.0]
  def change
    create_table :services do |t|
      t.string :name, null: false, limit: 50
      t.string :slug, null: false
      t.text :description, null: false
      t.text :full_description, null: false
      t.integer :category, null: false, default: 0
      t.integer :status, null: false, default: 0
      t.boolean :featured, default: false
      t.decimal :base_price, precision: 10, scale: 2
      t.integer :typical_duration_weeks
      t.json :deliverables, default: []
      t.json :process_steps, default: []
      
      t.timestamps
    end
    
    add_index :services, :slug, unique: true
    add_index :services, :category
    add_index :services, :status
    add_index :services, :featured
  end
end

# db/migrate/003_create_technologies.rb
class CreateTechnologies < ActiveRecord::Migration[8.0]
  def change
    create_table :technologies do |t|
      t.string :name, null: false, limit: 50
      t.integer :category, null: false, default: 0
      t.integer :proficiency_level, null: false, default: 2
      t.string :icon_url
      t.string :color_hex, default: '#6B7280'
      t.text :description
      t.string :official_url
      
      t.timestamps
    end
    
    add_index :technologies, :name, unique: true
    add_index :technologies, :category
    add_index :technologies, :proficiency_level
  end
end

# db/migrate/004_create_projects.rb
class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.string :title, null: false, limit: 100
      t.string :slug, null: false
      t.text :description, null: false
      t.text :challenge, null: false
      t.text :solution, null: false
      t.text :results, null: false
      t.integer :status, null: false, default: 0
      t.integer :budget_range, null: false, default: 0
      t.integer :duration_months, null: false
      t.integer :team_size, null: false
      t.date :started_at
      t.date :completed_at
      t.string :project_url
      t.string :github_url
      t.decimal :investment_amount, precision: 12, scale: 2
      t.decimal :return_amount, precision: 12, scale: 2
      t.boolean :featured, default: false
      t.datetime :deleted_at
      
      t.references :client, null: false, foreign_key: true
      
      t.timestamps
    end
    
    add_index :projects, :slug, unique: true
    add_index :projects, :status
    add_index :projects, :budget_range
    add_index :projects, :featured
    add_index :projects, :completed_at
    add_index :projects, :deleted_at
  end
end

# db/migrate/005_create_leads.rb
class CreateLeads < ActiveRecord::Migration[8.0]
  def change
    create_table :leads do |t|
      t.string :name, null: false, limit: 100
      t.string :email, null: false
      t.string :phone
      t.string :company, limit: 100
      t.integer :project_type, null: false, default: 4
      t.integer :budget_range, null: false, default: 0
      t.integer :timeline, null: false, default: 3
      t.text :message
      t.integer :status, null: false, default: 0
      t.integer :lead_score, default: 0
      t.datetime :contacted_at
      t.datetime :qualified_at
      t.text :notes
      t.json :utm_params, default: {}
      
      t.timestamps
    end
    
    add_index :leads, :email
    add_index :leads, :status
    add_index :leads, :lead_score
    add_index :leads, :created_at
  end
end

# db/migrate/006_create_testimonials.rb
class CreateTestimonials < ActiveRecord::Migration[8.0]
  def change
    create_table :testimonials do |t|
      t.text :content, null: false
      t.string :author_name, null: false, limit: 100
      t.string :author_title, null: false, limit: 100
      t.string :author_avatar_url
      t.integer :rating, null: false
      t.integer :status, null: false, default: 0
      
      t.references :client, null: false, foreign_key: true
      t.references :project, null: true, foreign_key: true
      
      t.timestamps
    end
    
    add_index :testimonials, :status
    add_index :testimonials, :rating
    add_index :testimonials, :created_at
  end
end

# db/migrate/007_create_project_metrics.rb
class CreateProjectMetrics < ActiveRecord::Migration[8.0]
  def change
    create_table :project_metrics do |t|
      t.string :metric_name, null: false, limit: 100
      t.decimal :before_value, null: false, precision: 12, scale: 2
      t.decimal :after_value, null: false, precision: 12, scale: 2
      t.string :unit, null: false, limit: 20
      t.integer :metric_type, null: false, default: 0
      t.text :description
      
      t.references :project, null: false, foreign_key: true
      
      t.timestamps
    end
    
    add_index :project_metrics, :metric_type
  end
end

# db/migrate/008_create_project_technologies.rb
class CreateProjectTechnologies < ActiveRecord::Migration[8.0]
  def change
    create_table :project_technologies do |t|
      t.references :project, null: false, foreign_key: true
      t.references :technology, null: false, foreign_key: true
      t.text :role_description
      
      t.timestamps
    end
    
    add_index :project_technologies, [:project_id, :technology_id], unique: true
  end
end

# db/migrate/009_create_project_services.rb
class CreateProjectServices < ActiveRecord::Migration[8.0]
  def change
    create_table :project_services do |t|
      t.references :project, null: false, foreign_key: true
      t.references :service, null: false, foreign_key: true
      t.boolean :primary_service, default: false
      
      t.timestamps
    end
    
    add_index :project_services, [:project_id, :service_id], unique: true
  end
end

# db/migrate/010_create_service_technologies.rb
class CreateServiceTechnologies < ActiveRecord::Migration[8.0]
  def change
    create_table :service_technologies do |t|
      t.references :service, null: false, foreign_key: true
      t.references :technology, null: false, foreign_key: true
      t.boolean :primary_tech, default: false
      
      t.timestamps
    end
    
    add_index :service_technologies, [:service_id, :technology_id], unique: true
  end
end

# db/seeds.rb
# Sample seed data following DDD principles

# Create Services
web_service = Service.create!(
  name: 'Web Development',
  description: 'Custom web applications built with modern frameworks',
  full_description: 'We build scalable, performant web applications using Ruby on Rails, React, and modern development practices. Our approach emphasizes clean architecture, comprehensive testing, and business-focused solutions.',
  category: 'web',
  featured: true,
  base_price: 15000,
  typical_duration_weeks: 12,
  deliverables: ['Custom web application', 'Admin dashboard', 'API documentation', 'Deployment setup'],
  process_steps: ['Discovery & planning', 'Design & prototyping', 'Development & testing', 'Deployment & training']
)

mobile_service = Service.create!(
  name: 'Mobile Development',
  description: 'Native iOS and Android applications',
  full_description: 'Cross-platform mobile applications using Swift, SwiftUI, and React Native. We focus on intuitive user experiences and seamless integration with web platforms.',
  category: 'mobile',
  featured: true,
  base_price: 25000,
  typical_duration_weeks: 16
)

data_service = Service.create!(
  name: 'Data Analytics',
  description: 'Custom dashboards and data visualization systems',
  full_description: 'Transform your business data into actionable insights with custom analytics platforms, real-time dashboards, and automated reporting systems.',
  category: 'data',
  featured: true,
  base_price: 20000,
  typical_duration_weeks: 10
)

# Create Technologies
rails = Technology.create!(name: 'Ruby on Rails', category: 'backend', proficiency_level: 'expert', color_hex: '#CC0000')
react = Technology.create!(name: 'React', category: 'frontend', proficiency_level: 'expert', color_hex: '#61DAFB')
swift = Technology.create!(name: 'Swift', category: 'mobile', proficiency_level: 'expert', color_hex: '#FA7343')
python = Technology.create!(name: 'Python', category: 'analytics', proficiency_level: 'advanced', color_hex: '#3776AB')
postgresql = Technology.create!(name: 'PostgreSQL', category: 'database', proficiency_level: 'expert', color_hex: '#336791')

# Associate services with technologies
web_service.technologies << [rails, react, postgresql]
mobile_service.technologies << [swift, react]
data_service.technologies << [python, postgresql, react]

# Create Sample Clients
client1 = Client.create!(
  name: 'TechFlow Solutions',
  industry: 'SaaS',
  company_size: 'growth',
  website: 'https://techflow.com',
  description: 'B2B workflow automation platform'
)

client2 = Client.create!(
  name: 'RetailMax Inc',
  industry: 'E-commerce',
  company_size: 'midmarket',
  website: 'https://retailmax.com',
  description: 'Multi-brand retail management platform'
)

# Create Sample Projects
project1 = Project.create!(
  title: 'TechFlow Dashboard Redesign',
  description: 'Complete overhaul of analytics dashboard with real-time data visualization',
  challenge: 'Legacy dashboard was slow, difficult to use, and provided limited insights into business metrics.',
  solution: 'Built new Rails 8 application with Hotwire for real-time updates, integrated with existing APIs, and implemented modern UI/UX patterns.',
  results: 'Improved user engagement by 180%, reduced page load times by 75%, and increased customer retention by 25%.',
  status: 'featured',
  budget_range: 'large',
  duration_months: 8,
  team_size: 4,
  completed_at: 3.months.ago,
  client: client1,
  featured: true
)

project1.services << [web_service, data_service]
project1.technologies << [rails, react, postgresql]

# Create metrics for the project
ProjectMetric.create!([
  {
    project: project1,
    metric_name: 'Page Load Time',
    before_value: 4.2,
    after_value: 1.1,
    unit: 'seconds',
    metric_type: 'performance'
  },
  {
    project: project1,
    metric_name: 'User Engagement',
    before_value: 45,
    after_value: 126,
    unit: 'minutes/session',
    metric_type: 'engagement'
  }
])

# Create testimonial
Testimonial.create!(
  content: 'The team delivered exactly what we needed. The new dashboard is intuitive, fast, and our users love it. ROI was evident within the first month.',
  author_name: 'Sarah Johnson',
  author_title: 'CTO',
  rating: 5,
  status: 'featured',
  client: client1,
  project: project1
)

puts "Seed data created successfully!"