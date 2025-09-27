# Gemfile
source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.0"

gem "rails", "~> 8.0.0"
gem "sprockets-rails", ">= 2.0.0"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "jbuilder"
gem "redis", ">= 4.0.1"
gem "bootsnap", require: false
gem "image_processing", "~> 1.2"
gem "friendly_id", "~> 5.5"
gem "meta-tags"
gem "acts_as_list"
gem "paranoia"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "shoulda-matchers"
end

group :development do
  gem "web-console"
  gem "spring"
  gem "spring-watcher-listen"
end

# Domain Models - Following DDD principles

# app/models/project.rb
class Project < ApplicationRecord
  extend FriendlyId
  friendly_id :title, use: :slugged
  
  include Paranoid
  
  belongs_to :client, class_name: 'Client'
  has_many :project_technologies, dependent: :destroy
  has_many :technologies, through: :project_technologies
  has_many :project_services, dependent: :destroy
  has_many :services, through: :project_services
  has_many :project_metrics, dependent: :destroy
  has_many_attached :images
  has_many_attached :documents
  
  validates :title, presence: true, length: { maximum: 100 }
  validates :description, presence: true, length: { maximum: 500 }
  validates :challenge, presence: true
  validates :solution, presence: true
  validates :results, presence: true
  validates :duration_months, presence: true, numericality: { greater_than: 0 }
  validates :team_size, presence: true, numericality: { greater_than: 0 }
  validates :budget_range, presence: true
  validates :status, inclusion: { in: %w[draft published featured archived] }
  
  scope :published, -> { where(status: 'published') }
  scope :featured, -> { where(status: 'featured') }
  scope :by_service, ->(service) { joins(:services).where(services: { id: service.id }) }
  scope :recent, -> { order(completed_at: :desc) }
  
  enum status: { draft: 0, published: 1, featured: 2, archived: 3 }
  enum budget_range: { 
    small: 0,      # < $25k
    medium: 1,     # $25k - $100k  
    large: 2,      # $100k - $500k
    enterprise: 3  # > $500k
  }
  
  def primary_service
    services.first
  end
  
  def roi_percentage
    return nil unless investment_amount && return_amount
    ((return_amount - investment_amount) / investment_amount * 100).round(1)
  end
  
  def tech_stack_list
    technologies.pluck(:name).join(', ')
  end
end

# app/models/client.rb
class Client < ApplicationRecord
  has_many :projects, dependent: :destroy
  has_many :testimonials, dependent: :destroy
  
  validates :name, presence: true, length: { maximum: 100 }
  validates :industry, presence: true
  validates :company_size, presence: true
  validates :website, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true
  
  enum company_size: { 
    startup: 0,     # 1-50 employees
    growth: 1,      # 51-200 employees  
    midmarket: 2,   # 201-1000 employees
    enterprise: 3   # 1000+ employees
  }
  
  scope :by_industry, ->(industry) { where(industry: industry) }
  scope :with_testimonials, -> { joins(:testimonials).distinct }
  
  def logo_url
    logo.present? ? logo : "https://ui-avatars.com/api/?name=#{name}&background=0D8ABC&color=fff"
  end
end

# app/models/service.rb
class Service < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: :slugged
  
  has_many :project_services, dependent: :destroy
  has_many :projects, through: :project_services
  has_many :service_technologies, dependent: :destroy
  has_many :technologies, through: :service_technologies
  has_one_attached :icon
  
  validates :name, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :description, presence: true, length: { maximum: 200 }
  validates :full_description, presence: true
  validates :category, inclusion: { in: %w[web mobile data consulting] }
  validates :status, inclusion: { in: %w[active inactive] }
  
  scope :active, -> { where(status: 'active') }
  scope :by_category, ->(category) { where(category: category) }
  scope :featured, -> { where(featured: true) }
  
  enum category: { web: 0, mobile: 1, data: 2, consulting: 3 }
  enum status: { active: 0, inactive: 1 }
  
  def project_count
    projects.published.count
  end
  
  def average_project_duration
    durations = projects.published.pluck(:duration_months)
    durations.any? ? (durations.sum.to_f / durations.count).round(1) : 0
  end
end

# app/models/technology.rb
class Technology < ApplicationRecord
  has_many :project_technologies, dependent: :destroy
  has_many :projects, through: :project_technologies
  has_many :service_technologies, dependent: :destroy  
  has_many :services, through: :service_technologies
  
  validates :name, presence: true, uniqueness: true, length: { maximum: 50 }
  validates :category, inclusion: { in: %w[frontend backend mobile database devops analytics] }
  validates :proficiency_level, inclusion: { in: %w[beginner intermediate advanced expert] }
  
  scope :by_category, ->(category) { where(category: category) }
  scope :expert_level, -> { where(proficiency_level: 'expert') }
  scope :popular, -> { joins(:projects).group('technologies.id').having('COUNT(projects.id) > 2') }
  
  enum category: { 
    frontend: 0, 
    backend: 1, 
    mobile: 2, 
    database: 3, 
    devops: 4, 
    analytics: 5 
  }
  
  enum proficiency_level: { 
    beginner: 0, 
    intermediate: 1, 
    advanced: 2, 
    expert: 3 
  }
  
  def usage_count
    projects.published.count
  end
end

# app/models/lead.rb
class Lead < ApplicationRecord
  validates :name, presence: true, length: { maximum: 100 }
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :company, length: { maximum: 100 }
  validates :project_type, inclusion: { in: %w[web mobile data consultation other] }
  validates :budget_range, inclusion: { in: %w[small medium large enterprise] }
  validates :timeline, inclusion: { in: %w[asap month quarter year] }
  validates :status, inclusion: { in: %w[new contacted qualified proposal closed] }
  
  scope :new_leads, -> { where(status: 'new') }
  scope :this_month, -> { where(created_at: Time.current.beginning_of_month..Time.current.end_of_month) }
  scope :by_budget, ->(budget) { where(budget_range: budget) }
  scope :by_timeline, ->(timeline) { where(timeline: timeline) }
  
  enum project_type: { web: 0, mobile: 1, data: 2, consultation: 3, other: 4 }
  enum budget_range: { small: 0, medium: 1, large: 2, enterprise: 3 }
  enum timeline: { asap: 0, month: 1, quarter: 2, year: 3 }
  enum status: { new: 0, contacted: 1, qualified: 2, proposal: 3, closed: 4 }
  
  # Lead scoring algorithm based on budget, timeline, and project complexity
  def calculate_score
    score = 0
    
    # Budget weight (40% of total score)
    score += budget_weight * 40
    
    # Timeline weight (30% of total score)  
    score += timeline_weight * 30
    
    # Project complexity weight (20% of total score)
    score += complexity_weight * 20
    
    # Company info completeness (10% of total score)
    score += completeness_weight * 10
    
    update(lead_score: score.round)
  end
  
  private
  
  def budget_weight
    case budget_range
    when 'enterprise' then 1.0
    when 'large' then 0.8
    when 'medium' then 0.6
    when 'small' then 0.3
    else 0.1
    end
  end
  
  def timeline_weight
    case timeline
    when 'asap' then 1.0
    when 'month' then 0.8
    when 'quarter' then 0.6
    when 'year' then 0.3
    else 0.1
    end
  end
  
  def complexity_weight
    case project_type
    when 'data' then 1.0
    when 'web' then 0.8
    when 'mobile' then 0.7
    when 'consultation' then 0.4
    else 0.3
    end
  end
  
  def completeness_weight
    fields = [company, phone, message].compact
    fields.count / 3.0
  end
end

# app/models/testimonial.rb
class Testimonial < ApplicationRecord
  belongs_to :client
  belongs_to :project, optional: true
  
  validates :content, presence: true, length: { maximum: 500 }
  validates :author_name, presence: true, length: { maximum: 100 }
  validates :author_title, presence: true, length: { maximum: 100 }
  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :status, inclusion: { in: %w[draft published featured] }
  
  scope :published, -> { where(status: 'published') }
  scope :featured, -> { where(status: 'featured') }
  scope :recent, -> { order(created_at: :desc) }
  scope :high_rated, -> { where('rating >= ?', 4) }
  
  enum status: { draft: 0, published: 1, featured: 2 }
end

# app/models/project_metric.rb
class ProjectMetric < ApplicationRecord
  belongs_to :project
  
  validates :metric_name, presence: true, length: { maximum: 100 }
  validates :before_value, presence: true
  validates :after_value, presence: true
  validates :unit, presence: true, length: { maximum: 20 }
  validates :metric_type, inclusion: { in: %w[performance conversion revenue engagement technical] }
  
  scope :by_type, ->(type) { where(metric_type: type) }
  
  enum metric_type: { 
    performance: 0, 
    conversion: 1, 
    revenue: 2, 
    engagement: 3, 
    technical: 4 
  }
  
  def improvement_percentage
    return 0 if before_value.zero?
    ((after_value - before_value) / before_value * 100).round(1)
  end
  
  def improvement_direction
    after_value > before_value ? 'increase' : 'decrease'
  end
end

# Join Tables
# app/models/project_technology.rb
class ProjectTechnology < ApplicationRecord
  belongs_to :project
  belongs_to :technology
  
  validates :project_id, uniqueness: { scope: :technology_id }
end

# app/models/project_service.rb  
class ProjectService < ApplicationRecord
  belongs_to :project
  belongs_to :service
  
  validates :project_id, uniqueness: { scope: :service_id }
end

# app/models/service_technology.rb
class ServiceTechnology < ApplicationRecord
  belongs_to :service
  belongs_to :technology
  
  validates :service_id, uniqueness: { scope: :technology_id }
end