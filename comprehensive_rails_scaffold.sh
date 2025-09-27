#!/bin/bash

# =============================================================================
# Digital Agency Platform - Comprehensive Rails Setup Script
# =============================================================================
# This script creates a complete Rails 8 application with all dependencies,
# configurations, and initial setup for a professional digital agency platform

set -e  # Exit on any error

echo "🚀 Creating Digital Agency Platform with Rails 8..."
echo "=============================================="

# Project configuration
PROJECT_NAME="digital-agency-platform"
RUBY_VERSION="3.2.0"
RAILS_VERSION="~> 8.0.0"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Utility functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check Ruby version
    if ! command -v ruby &> /dev/null; then
        log_error "Ruby is not installed. Please install Ruby $RUBY_VERSION"
        exit 1
    fi
    
    current_ruby=$(ruby -v | awk '{print $2}')
    log_success "Ruby version: $current_ruby"
    
    # Check Node.js
    if ! command -v node &> /dev/null; then
        log_error "Node.js is not installed. Please install Node.js 18+"
        exit 1
    fi
    
    current_node=$(node -v)
    log_success "Node.js version: $current_node"
    
    # Check PostgreSQL
    if ! command -v psql &> /dev/null; then
        log_warning "PostgreSQL not found. Please ensure it's installed and running"
    else
        log_success "PostgreSQL is available"
    fi
    
    # Check Redis
    if ! command -v redis-cli &> /dev/null; then
        log_warning "Redis not found. Please ensure it's installed and running"
    else
        log_success "Redis is available"
    fi
}

# Create the Rails application
create_rails_app() {
    log_info "Creating Rails application..."
    
    # Rails new command with comprehensive options
    rails new $PROJECT_NAME \
        --database=postgresql \
        --css=tailwind \
        --javascript=importmap \
        --skip-action-cable \
        --skip-jbuilder \
        --skip-system-test \
        --skip-bundle \
        --force
    
    cd $PROJECT_NAME
    log_success "Rails application '$PROJECT_NAME' created"
}

# Setup comprehensive Gemfile
setup_gemfile() {
    log_info "Setting up comprehensive Gemfile..."
    
    cat > Gemfile << 'EOF'
source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.0"

# Core Rails
gem "rails", "~> 8.0.0"

# Database & Storage
gem "pg", "~> 1.5"
gem "redis", ">= 4.0.1"

# Web Server
gem "puma", ">= 5.0"

# Frontend
gem "sprockets-rails", ">= 2.0.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"

# Background Jobs
gem "sidekiq", "~> 7.0"
gem "sidekiq-scheduler"

# File Processing
gem "image_processing", "~> 1.2"
gem "active_storage_validations"

# Business Logic
gem "friendly_id", "~> 5.5"
gem "paranoia", "~> 2.6"
gem "acts_as_list"
gem "kaminari"

# SEO & Marketing
gem "meta-tags"
gem "sitemap_generator"

# API & Serialization
gem "jbuilder"
gem "fast_jsonapi"

# Authentication & Authorization
gem "devise"
gem "pundit"

# Forms & Validation
gem "simple_form"

# External Integrations
gem "httparty"
gem "faraday"
gem "faraday-retry"

# CRM Integration
gem "hubspot-api-client"
gem "restforce" # Salesforce

# Email
gem "sendgrid-ruby"

# Analytics & Monitoring
gem "google-analytics-rails", "~> 1.1.0"

# Caching
gem "redis-rails"

# Performance & Optimization
gem "bootsnap", require: false
gem "rack-attack"
gem "rack-cors"

# Environment Variables
gem "dotenv-rails"

# Debugging (development)
gem "debug", platforms: %i[ mri windows ]

group :development, :test do
  # Testing Framework
  gem "rspec-rails", "~> 6.0"
  gem "factory_bot_rails"
  gem "faker"
  gem "shoulda-matchers"
  
  # Code Quality
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  
  # Security
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  
  # Database
  gem "database_cleaner-active_record"
end

group :development do
  # Development Tools
  gem "web-console"
  gem "spring"
  gem "spring-watcher-listen"
  gem "listen"
  
  # Email Testing
  gem "letter_opener"
  gem "mailcatcher", require: false
  
  # Performance Monitoring
  gem "bullet"
  gem "rack-mini-profiler"
  gem "memory_profiler"
  gem "stackprof"
  
  # Documentation
  gem "annotate"
end

group :test do
  # System Testing
  gem "capybara"
  gem "selenium-webdriver"
  gem "webdrivers"
  
  # Test Coverage
  gem "simplecov", require: false
  
  # API Testing
  gem "webmock"
  gem "vcr"
end

group :production do
  # Error Tracking
  gem "sentry-ruby"
  gem "sentry-rails"
  
  # Performance Monitoring
  gem "newrelic_rpm"
  
  # Asset Compression
  gem "terser"
end
EOF

    log_success "Comprehensive Gemfile created"
}

# Setup package.json with frontend dependencies
setup_package_json() {
    log_info "Setting up package.json..."
    
    cat > package.json << 'EOF'
{
  "name": "digital-agency-platform",
  "version": "1.0.0",
  "description": "Digital agency showcase platform for lead generation",
  "main": "app/javascript/application.js",
  "scripts": {
    "build": "webpack --mode=production",
    "build:dev": "webpack --mode=development", 
    "watch": "webpack --mode=development --watch",
    "watch:css": "tailwindcss -i ./app/assets/stylesheets/application.tailwind.css -o ./app/assets/builds/application.css --watch",
    "build:css": "tailwindcss -i ./app/assets/stylesheets/application.tailwind.css -o ./app/assets/builds/application.css --minify",
    "test:js": "jest",
    "lint:js": "eslint app/javascript",
    "lint:css": "stylelint app/assets/stylesheets",
    "format": "prettier --write app/javascript"
  },
  "dependencies": {
    "@hotwired/stimulus": "^3.2.2",
    "@hotwired/turbo-rails": "^8.0.0",
    "tailwindcss": "^3.4.0",
    "autoprefixer": "^10.4.16",
    "postcss": "^8.4.32",
    "chart.js": "^4.4.0",
    "alpinejs": "^3.13.0"
  },
  "devDependencies": {
    "@tailwindcss/forms": "^0.5.7",
    "@tailwindcss/typography": "^0.5.10",
    "@tailwindcss/aspect-ratio": "^0.4.2",
    "eslint": "^8.55.0",
    "eslint-config-standard": "^17.1.0",
    "jest": "^29.7.0",
    "prettier": "^3.1.0",
    "stylelint": "^15.11.0",
    "stylelint-config-standard": "^34.0.0",
    "webpack": "^5.89.0",
    "webpack-cli": "^5.1.4"
  },
  "engines": {
    "node": ">=18.0.0",
    "npm": ">=9.0.0"
  }
}
EOF

    log_success "Package.json created"
}

# Create comprehensive database configuration
setup_database_config() {
    log_info "Setting up database configuration..."
    
    cat > config/database.yml << 'EOF'
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("DB_POOL") { 10 } %>
  timeout: 5000
  host: <%= ENV.fetch("DB_HOST") { "localhost" } %>
  port: <%= ENV.fetch("DB_PORT") { 5432 } %>
  username: <%= ENV.fetch("DB_USERNAME") { "postgres" } %>
  password: <%= ENV.fetch("DB_PASSWORD") { "" } %>

development:
  <<: *default
  database: <%= ENV.fetch("DB_NAME") { "agency_development" } %>

test:
  <<: *default
  database: <%= ENV.fetch("DB_NAME_TEST") { "agency_test" } %>

production:
  <<: *default
  url: <%= ENV['DATABASE_URL'] %>
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
EOF

    log_success "Database configuration created"
}

# Create environment configuration
create_env_files() {
    log_info "Creating environment configuration..."
    
    cat > .env.example << 'EOF'
# Rails Configuration
RAILS_ENV=development
SECRET_KEY_BASE=your_secret_key_base_here
RAILS_MASTER_KEY=your_rails_master_key_here

# Database Configuration
DB_HOST=localhost
DB_PORT=5432
DB_USERNAME=postgres
DB_PASSWORD=
DB_NAME=agency_development
DB_NAME_TEST=agency_test
DATABASE_URL=postgresql://postgres@localhost:5432/agency_development
REDIS_URL=redis://localhost:6379/0

# Email Configuration
SMTP_HOST=localhost
SMTP_PORT=1025
SMTP_USERNAME=
SMTP_PASSWORD=
SUPPORT_EMAIL=support@yourcompany.com

# CRM Integration
HUBSPOT_ACCESS_TOKEN=your_hubspot_token
SALESFORCE_CLIENT_ID=your_salesforce_client_id
SALESFORCE_CLIENT_SECRET=your_salesforce_secret

# Analytics
GOOGLE_ANALYTICS_ID=G-XXXXXXXXXX
HOTJAR_ID=your_hotjar_id

# Security
SESSION_TIMEOUT=7200
RACK_ATTACK_ENABLED=true

# Background Jobs
SIDEKIQ_CONCURRENCY=10
EOF

    # Copy to actual .env file
    cp .env.example .env
    
    log_success "Environment files created"
}

# Setup application configuration
setup_app_config() {
    log_info "Setting up application configuration..."
    
    # Create application.rb configuration
    cat > config/application.rb << 'EOF'
require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module DigitalAgencyPlatform
  class Application < Rails::Application
    config.load_defaults 8.0
    
    # Configuration for the application
    config.time_zone = 'UTC'
    
    # CORS configuration
    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins ENV.fetch('ALLOWED_ORIGINS', 'localhost:3000').split(',')
        resource '*',
          headers: :any,
          methods: [:get, :post, :put, :patch, :delete, :options, :head],
          credentials: true
      end
    end
    
    # Active Storage configuration
    config.active_storage.variant_processor = :vips
    
    # Active Job configuration
    config.active_job.queue_adapter = :sidekiq
    
    # Generators configuration
    config.generators do |g|
      g.test_framework :rspec,
        fixtures: false,
        view_specs: false,
        helper_specs: false,
        routing_specs: false
      g.factory_bot dir: 'spec/factories'
      g.assets false
      g.helper false
    end
    
    # Autoload paths
    config.autoload_paths += %W(#{config.root}/app/services)
    config.autoload_paths += %W(#{config.root}/app/jobs)
    
    # Security configuration
    config.force_ssl = Rails.env.production?
    
    # Session configuration
    config.session_store :redis_session_store, {
      key: '_agency_session',
      redis: {
        expire_after: 2.weeks,
        key_prefix: 'agency:session:',
        url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0')
      }
    }
  end
end
EOF

    log_success "Application configuration updated"
}

# Create initializers
create_initializers() {
    log_info "Creating initializers..."
    
    # Redis initializer
    cat > config/initializers/redis.rb << 'EOF'
$redis = Redis.new(
  url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0'),
  timeout: 1,
  reconnect_attempts: 3,
  reconnect_delay: 0.5
)
EOF

    # Sidekiq initializer
    cat > config/initializers/sidekiq.rb << 'EOF'
Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/0') }
end
EOF

    # Rack Attack initializer
    cat > config/initializers/rack_attack.rb << 'EOF'
return unless ENV.fetch('RACK_ATTACK_ENABLED', 'false') == 'true'

class Rack::Attack
  # Throttle requests by IP
  throttle('req/ip', limit: 300, period: 5.minutes) do |req|
    req.ip
  end

  # Throttle contact form submissions
  throttle('contact/ip', limit: 5, period: 1.hour) do |req|
    req.ip if req.path == '/leads' && req.post?
  end

  # Throttle API requests
  throttle('api/ip', limit: 100, period: 1.hour) do |req|
    req.ip if req.path.start_with?('/api/')
  end
end
EOF

    # CORS initializer
    cat > config/initializers/cors.rb << 'EOF'
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch('ALLOWED_ORIGINS', 'localhost:3000').split(',')
    
    resource '*',
      headers: :any,
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end
end
EOF

    log_success "Initializers created"
}

# Create routes configuration
setup_routes() {
    log_info "Setting up routes..."
    
    cat > config/routes.rb << 'EOF'
Rails.application.routes.draw do
  # Health check
  get '/health', to: 'health#show'
  
  # Admin routes
  devise_for :admin_users, path: 'admin', controllers: {
    sessions: 'admin/sessions'
  }
  
  namespace :admin do
    root 'dashboard#index'
    resources :projects do
      resources :project_metrics, except: [:show]
    end
    resources :clients
    resources :services do
      resources :service_technologies, except: [:show]
    end
    resources :technologies
    resources :testimonials
    resources :leads do
      member do
        patch :update_status
      end
      collection do
        post :bulk_update
      end
    end
    resources :users
  end
  
  # API routes
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :leads, only: [:create, :show, :update]
      resources :projects, only: [:index, :show]
      resources :services, only: [:index, :show]
    end
  end
  
  # Webhook routes
  namespace :webhooks do
    post '/hubspot', to: 'hubspot#handle'
    post '/salesforce', to: 'salesforce#handle'
  end
  
  # Public routes
  root 'home#index'
  
  resources :projects, only: [:index, :show], path: 'work' do
    collection do
      get :filter
    end
  end
  
  resources :services, only: [:index, :show]
  resources :leads, only: [:create]
  
  get '/contact', to: 'contact#index'
  post '/contact', to: 'contact#create'
  
  get '/about', to: 'pages#about'
  get '/process', to: 'pages#process'
  get '/blog', to: 'blog#index'
  
  # SEO routes
  get '/sitemap.xml', to: 'sitemap#show', format: :xml
  get '/robots.txt', to: 'robots#show', format: :text
  
  # Error pages
  match '/404', to: 'errors#not_found', via: :all
  match '/422', to: 'errors#unprocessable_entity', via: :all  
  match '/500', to: 'errors#internal_server_error', via: :all
end
EOF

    log_success "Routes configuration created"
}

# Generate comprehensive migrations
generate_migrations() {
    log_info "Generating database migrations..."
    
    # Generate Devise configuration first
    bundle exec rails generate devise:install
    bundle exec rails generate devise Admin
    
    # Generate core models
    bundle exec rails generate model Client name:string industry:string company_size:integer website:string logo:string description:text location:string founded_year:integer
    
    bundle exec rails generate model Service name:string slug:string description:text full_description:text category:integer status:integer featured:boolean base_price:decimal typical_duration_weeks:integer
    
    bundle exec rails generate model Technology name:string category:integer proficiency_level:integer icon_url:string color_hex:string description:text official_url:string
    
    bundle exec rails generate model Project title:string slug:string description:text challenge:text solution:text results:text status:integer budget_range:integer duration_months:integer team_size:integer started_at:date completed_at:date project_url:string github_url:string investment_amount:decimal return_amount:decimal featured:boolean client:references deleted_at:timestamp
    
    bundle exec rails generate model Lead name:string email:string phone:string company:string project_type:integer budget_range:integer timeline:integer message:text status:integer lead_score:integer contacted_at:timestamp qualified_at:timestamp notes:text
    
    bundle exec rails generate model Testimonial content:text author_name:string author_title:string author_avatar_url:string rating:integer status:integer client:references project:references
    
    bundle exec rails generate model ProjectMetric metric_name:string before_value:decimal after_value:decimal unit:string metric_type:integer description:text project:references
    
    # Generate join tables
    bundle exec rails generate model ProjectTechnology project:references technology:references role_description:text
    bundle exec rails generate model ProjectService project:references service:references primary_service:boolean
    bundle exec rails generate model ServiceTechnology service:references technology:references primary_tech:boolean
    
    # Generate activity tracking
    bundle exec rails generate model LeadActivity lead:references activity_type:integer description:text user_email:string
    
    log_success "Database migrations generated"
}

# Create controllers
generate_controllers() {
    log_info "Generating controllers..."
    
    # Generate public controllers
    bundle exec rails generate controller Home index
    bundle exec rails generate controller Projects index show
    bundle exec rails generate controller Services index show
    bundle exec rails generate controller Leads create
    bundle exec rails generate controller Contact index create
    bundle exec rails generate controller Pages about process
    bundle exec rails generate controller Health show
    
    # Generate admin controllers
    mkdir -p app/controllers/admin
    bundle exec rails generate controller Admin::Dashboard index
    bundle exec rails generate controller Admin::Projects index show new edit create update destroy
    bundle exec rails generate controller Admin::Clients index show new edit create update destroy
    bundle exec rails generate controller Admin::Services index show new edit create update destroy
    bundle exec rails generate controller Admin::Technologies index show new edit create update destroy
    bundle exec rails generate controller Admin::Testimonials index show new edit create update destroy
    bundle exec rails generate controller Admin::Leads index show update
    
    # Generate API controllers
    mkdir -p app/controllers/api/v1
    bundle exec rails generate controller Api::V1::Leads create show update
    bundle exec rails generate controller Api::V1::Projects index show
    
    log_success "Controllers generated"
}

# Create service objects
create_service_objects() {
    log_info "Creating service objects..."
    
    mkdir -p app/services
    
    cat > app/services/lead_scoring_service.rb << 'EOF'
class LeadScoringService
  def initialize(lead)
    @lead = lead
  end
  
  def calculate_score
    score = budget_weight * 0.35 + 
            timeline_weight * 0.25 + 
            complexity_weight * 0.20 + 
            quality_weight * 0.10 + 
            completeness_weight * 0.10
    
    (score * 100).round
  end
  
  private
  
  attr_reader :lead
  
  def budget_weight
    case lead.budget_range
    when 'enterprise' then 1.0
    when 'large' then 0.85
    when 'medium' then 0.65
    when 'small' then 0.35
    else 0.1
    end
  end
  
  def timeline_weight
    case lead.timeline
    when 'asap' then 1.0
    when 'month' then 0.85
    when 'quarter' then 0.65
    when 'year' then 0.35
    else 0.1
    end
  end
  
  def complexity_weight
    case lead.project_type
    when 'data' then 1.0
    when 'web' then 0.85
    when 'mobile' then 0.75
    when 'consultation' then 0.45
    else 0.25
    end
  end
  
  def quality_weight
    score = 0.0
    
    # Email domain quality
    if lead.email.present?
      domain = lead.email.split('@').last.downcase
      score += 0.3 unless %w[gmail.com yahoo.com hotmail.com].include?(domain)
    end
    
    # Message detail
    if lead.message.present?
      word_count = lead.message.split.length
      score += 0.4 if word_count > 20
      score += 0.2 if word_count > 10
    end
    
    # Phone provided
    score += 0.3 if lead.phone.present?
    
    [score, 1.0].min
  end
  
  def completeness_weight
    fields_present = [
      lead.company.present? ? 1 : 0,
      lead.phone.present? ? 1 : 0,
      lead.message.present? ? 1 : 0
    ].sum
    
    fields_present / 3.0
  end
end
EOF

    cat > app/services/crm_integration_service.rb << 'EOF'
class CrmIntegrationService
  def initialize(lead)
    @lead = lead
  end
  
  def sync_to_hubspot
    return unless hubspot_enabled?
    
    # HubSpot integration logic here
    # This would use the hubspot-api-client gem
    true
  rescue => e
    Rails.logger.error "HubSpot sync failed: #{e.message}"
    false
  end
  
  def sync_to_salesforce
    return unless salesforce_enabled?
    
    # Salesforce integration logic here
    # This would use the restforce gem
    true
  rescue => e
    Rails.logger.error "Salesforce sync failed: #{e.message}"
    false
  end
  
  private
  
  def hubspot_enabled?
    ENV['HUBSPOT_ACCESS_TOKEN'].present?
  end
  
  def salesforce_enabled?
    ENV['SALESFORCE_CLIENT_ID'].present?
  end
end
EOF

    log_success "Service objects created"
}

# Create background jobs
create_background_jobs() {
    log_info "Creating background jobs..."
    
    mkdir -p app/jobs
    
    cat > app/jobs/lead_workflow_job.rb << 'EOF'
class LeadWorkflowJob < ApplicationJob
  queue_as :default
  
  def perform(lead_id)
    lead = Lead.find(lead_id)
    
    # Calculate lead score
    lead.update!(lead_score: LeadScoringService.new(lead).calculate_score)
    
    # Log activity
    LeadActivity.create!(
      lead: lead,
      activity_type: 'created',
      description: 'Lead created from website form',
      user_email: 'system'
    )
    
    # CRM sync
    CrmIntegrationService.new(lead).sync_to_hubspot
    
    # Schedule follow-up based on score
    if lead.lead_score >= 80
      AdminNotificationJob.perform_now(lead.id, 'high_priority_lead')
    elsif lead.lead_score >= 50
      LeadFollowUpJob.perform_in(2.hours, lead.id)
    else
      LeadFollowUpJob.perform_at(next_business_day, lead.id)
    end
  end
  
  private
  
  def next_business_day
    date = 1.day.from_now
    date += 1.day while date.saturday? || date.sunday?
    date.beginning_of_day + 9.hours
  end
end
EOF

    cat > app/jobs/lead_follow_up_job.rb << 'EOF'
class LeadFollowUpJob < ApplicationJob
  queue_as :default
  
  def perform(lead_id)
    lead = Lead.find(lead_id)
    
    # Send follow-up email
    LeadMailer.follow_up_email(lead).deliver_now
    
    # Log activity
    LeadActivity.create!(
      lead: lead,
      activity_type: 'email_sent',
      description: 'Follow-up email sent',
      user_email: 'system'
    )
  end
end
EOF

    log_success "Background jobs created"
}

# Create comprehensive specs
create_specs() {
    log_info "Setting up RSpec configuration..."
    
    bundle exec rails generate rspec:install
    
    # Update rails_helper.rb
    cat > spec/rails_helper.rb << 'EOF'
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'shoulda-matchers'
require 'factory_bot_rails'

Dir[Rails.root.join('spec', 'support', '**', '*.rb')].sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end

RSpec.configure do |config|
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!
  
  # Factory Bot
  config.include FactoryBot::Syntax::Methods
  
  # Database Cleaner
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end
  
  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
  
  # System tests
  config.before(:each, type: :system) do
    driven_by :rack_test
  end
  
  config.before(:each, type: :system, js: true) do
    driven_by :selenium_chrome_headless
  end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end
EOF

    # Create factory files
    mkdir -p spec/factories
    
    cat > spec/factories/leads.rb << 'EOF'
FactoryBot.define do
  factory :lead do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    phone { Faker::PhoneNumber.phone_number }
    company { Faker::Company.name }
    project_type { ['web', 'mobile', 'data', 'consultation'].sample }
    budget_range { ['small', 'medium', 'large', 'enterprise'].sample }
    timeline { ['asap', 'month', 'quarter', 'year'].sample }
    message { Faker::Lorem.paragraph(sentence_count: 4) }
    status { 'new' }
    lead_score { 0 }
    
    trait :high_score do
      budget_range { 'enterprise' }
      timeline { 'asap' }
      project_type { 'data' }
      company { 'Enterprise Corp' }
      phone { '+1234567890' }
      message { 'Comprehensive data analytics platform needed urgently.' }
    end
  end
end
EOF

    log_success "RSpec configuration created"
}

# Create development scripts
create_development_scripts() {
    log_info "Creating development scripts..."
    
    # Setup script
    cat > bin/setup << 'EOF'
#!/usr/bin/env ruby
require "fileutils"

APP_ROOT = File.expand_path("..", __dir__)

def system!(*args)
  system(*args, exception: true)
end

FileUtils.chdir APP_ROOT do
  puts "== Installing dependencies =="
  system! "gem install bundler --conservative"
  system("bundle check") || system!("bundle install")
  system!("npm install")

  puts "\n== Preparing database =="
  system! "bin/rails db:prepare"

  puts "\n== Removing old logs and tempfiles =="
  system! "bin/rails log:clear tmp:clear"

  puts "\n== Setting up environment =="
  unless File.exist?(".env")
    puts "Copying .env.example to .env..."
    system! "cp .env.example .env"
  end

  puts "\n== Running tests =="
  system! "bundle exec rspec --format progress"

  puts "\n== Project setup complete! =="
  puts "Start with: bin/dev"
end
EOF

    chmod +x bin/setup
    
    # Development start script
    cat > bin/dev << 'EOF'
#!/usr/bin/env sh

if ! gem list --silent foreman | grep foreman > /dev/null; then
  echo "Installing foreman..."
  gem install foreman
fi

exec foreman start -f Procfile.dev "$@"
EOF

    chmod +x bin/dev
    
    # Procfile for development
    cat > Procfile.dev << 'EOF'
web: bundle exec rails server -p 3000
js: npm run watch
css: npm run watch:css
worker: bundle exec sidekiq
mailcatcher: mailcatcher --foreground --http-ip=0.0.0.0
EOF

    log_success "Development scripts created"
}

# Final setup and instructions
final_setup() {
    log_info "Running final setup..."
    
    # Install gems
    bundle install
    
    # Install npm packages
    npm install
    
    # Generate secret key
    SECRET_KEY=$(bundle exec rails secret)
    sed -i.bak "s/your_secret_key_base_here/$SECRET_KEY/" .env
    rm .env.bak
    
    # Setup database
    bundle exec rails db:create
    bundle exec rails db:migrate
    
    # Generate sample data
    bundle exec rails db:seed
    
    # Run tests
    bundle exec rspec --format documentation
    
    log_success "Final setup completed!"
}

# Display completion message
show_completion_message() {
    echo ""
    echo "🎉 Digital Agency Platform Setup Complete!"
    echo "=============================================="
    echo ""
    log_success "Your Rails 8 application is ready!"
    echo ""
    echo "📁 Project: $PROJECT_NAME"
    echo "🚀 Rails version: $(bundle exec rails --version)"
    echo "💎 Ruby version: $(ruby --version)"
    echo ""
    echo "Next steps:"
    echo "1. cd $PROJECT_NAME"
    echo "2. Review and customize .env file"
    echo "3. Start development server: bin/dev"
    echo "4. Visit: http://localhost:3000"
    echo ""
    echo "Admin panel: http://localhost:3000/admin"
    echo "Health check: http://localhost:3000/health"
    echo "Mailcatcher: http://localhost:1080 (for development emails)"
    echo ""
    echo "📚 Key directories:"
    echo "   app/models/     - Domain models"
    echo "   app/services/   - Business logic"
    echo "   app/jobs/       - Background jobs"
    echo "   spec/           - Test files"
    echo ""
    echo "🔧 Useful commands:"
    echo "   bin/setup       - Setup project"
    echo "   bin/dev         - Start all services"
    echo "   bundle exec rspec - Run tests"
    echo "   rails console   - Interactive console"
    echo ""
    log_success "Happy coding! 🚀"
}

# Main execution flow
main() {
    echo "Starting comprehensive Rails setup..."
    
    check_prerequisites
    create_rails_app
    setup_gemfile
    setup_package_json
    setup_database_config
    create_env_files
    setup_app_config
    create_initializers
    setup_routes
    generate_migrations
    generate_controllers
    create_service_objects
    create_background_jobs
    create_specs
    create_development_scripts
    final_setup
    show_completion_message
}

# Run the main function
main "$@"
