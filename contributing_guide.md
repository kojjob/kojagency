# Contributing to Digital Agency Showcase Platform

Thank you for considering contributing to our project! This guide will help you understand our development process and standards.

## 🎯 Project Philosophy

This platform demonstrates technical excellence while focusing on business results. Every contribution should align with our core principles:

- **Business-First Development**: Technical decisions support business objectives
- **Quality Over Speed**: Maintainable, tested, secure code
- **User-Centric Design**: Focus on conversion and professional presentation
- **Performance Mindset**: Optimize for speed and scalability
- **Security Awareness**: Consider security implications in all changes

## 🚀 Getting Started

### Development Environment Setup

1. **Fork and Clone**
```bash
git clone https://github.com/your-username/agency-platform.git
cd agency-platform
```

2. **Install Dependencies**
```bash
bundle install
npm install
```

3. **Setup Database**
```bash
rails db:create db:migrate db:seed
```

4. **Run Tests**
```bash
bundle exec rspec
```

5. **Start Development Server**
```bash
rails server
```

## 🏗️ Development Workflow

### Branch Strategy
- `main`: Production-ready code
- `develop`: Integration branch for features
- `feature/feature-name`: Feature development
- `hotfix/issue-name`: Critical production fixes

### Commit Message Format
```
type(scope): description

[optional body]

[optional footer]
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

**Examples**:
```
feat(lead-scoring): add enterprise budget weight factor
fix(contact-form): prevent duplicate submissions
docs(readme): update deployment instructions
test(models): add project validation specs
```

### Pull Request Process

1. **Create Feature Branch**
```bash
git checkout -b feature/your-feature-name
```

2. **Develop with TDD**
```bash
# Write failing test first
bundle exec rspec spec/models/your_model_spec.rb

# Implement feature
# Make test pass
```

3. **Ensure Quality**
```bash
# Run all tests
bundle exec rspec

# Check security
bundle audit

# Verify performance impact
bundle exec rails runner "puts Benchmark.measure { YourClass.new.your_method }"
```

4. **Create Pull Request**
- Provide clear description of changes
- Reference related issues
- Include screenshots for UI changes
- Ensure all checks pass

## 🧪 Testing Standards

### Test-Driven Development (TDD)
We follow strict TDD practices:

1. **Red**: Write failing test first
2. **Green**: Write minimal code to pass test
3. **Refactor**: Improve code while keeping tests green

### Test Coverage Requirements
- **Minimum Coverage**: 90% overall
- **Models**: 95% coverage required
- **Controllers**: 85% coverage required
- **Critical Business Logic**: 100% coverage required

### Test Categories

#### Unit Tests (Models)
```ruby
# spec/models/lead_spec.rb
RSpec.describe Lead, type: :model do
  describe '#calculate_score' do
    context 'with enterprise budget and urgent timeline' do
      let(:lead) { build(:lead, budget_range: 'enterprise', timeline: 'asap') }
      
      it 'returns high priority score' do
        expect(lead.calculate_score).to be >= 80
      end
    end
  end
end
```

#### Integration Tests (Controllers)
```ruby
# spec/controllers/leads_controller_spec.rb
RSpec.describe LeadsController, type: :controller do
  describe 'POST #create' do
    let(:valid_attributes) { attributes_for(:lead) }
    
    it 'creates lead and triggers workflow' do
      expect { post :create, params: { lead: valid_attributes } }
        .to change(Lead, :count).by(1)
        .and have_enqueued_job(LeadWorkflowJob)
    end
  end
end
```

#### System Tests (End-to-End)
```ruby
# spec/system/lead_submission_spec.rb
RSpec.describe 'Lead Submission', type: :system, js: true do
  it 'successfully submits qualified lead' do
    visit root_path
    fill_in 'Name', with: 'Enterprise Client'
    select '$500k+', from: 'Budget Range'
    click_button 'Get Free Estimate'
    
    expect(page).to have_content('Thank you')
    expect(Lead.last.lead_score).to be >= 70
  end
end
```

## 💻 Code Quality Standards

### Ruby/Rails Conventions

#### Model Development
```ruby
class Lead < ApplicationRecord
  # Constants first
  BUDGET_RANGES = %w[small medium large enterprise].freeze
  
  # Associations
  has_many :lead_activities, dependent: :destroy
  
  # Validations (order by importance)
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :budget_range, inclusion: { in: BUDGET_RANGES }
  
  # Scopes
  scope :high_priority, -> { where('lead_score >= 80') }
  scope :this_month, -> { where(created_at: Time.current.beginning_of_month..) }
  
  # Instance methods (public first)
  def high_priority?
    lead_score >= 80
  end
  
  def calculate_score
    LeadScoringService.new(self).calculate_score
  end
  
  private
  
  # Private methods
end
```

#### Service Objects
```ruby
class LeadScoringService
  def initialize(lead)
    @lead = lead
  end
  
  def calculate_score
    score = budget_weight * 0.35 + 
            timeline_weight * 0.25 + 
            complexity_weight * 0.20 + 
            quality_weight * 0.20
    
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
end
```

#### Controller Patterns
```ruby
class ProjectsController < ApplicationController
  before_action :set_project, only: [:show]
  
  def index
    @projects = Project.published
                      .includes(:client, :services, :technologies)
                      .recent
    
    apply_filters if filter_params.any?
    
    respond_to do |format|
      format.html
      format.turbo_stream # Hotwire support
    end
  end
  
  private
  
  def set_project
    @project = Project.published.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to projects_path, alert: "Project not found."
  end
  
  def filter_params
    params.permit(:service_id, :technology_id, :budget_range)
  end
end
```

### Frontend Development

#### TailwindCSS Patterns
```erb
<!-- Component-based approach -->
<div class="bg-white rounded-xl shadow-lg hover:shadow-2xl transition-all duration-300 p-8 group">
  <div class="w-16 h-16 bg-primary-100 rounded-lg flex items-center justify-center mb-6 group-hover:bg-primary-500 transition-colors">
    <!-- Icon content -->
  </div>
  
  <h3 class="text-2xl font-bold text-gray-900 mb-4 group-hover:text-primary-600 transition-colors">
    <%= content %>
  </h3>
  
  <!-- Rest of component -->
</div>
```

#### Stimulus Controllers
```javascript
// app/javascript/controllers/lead_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["score", "budget", "timeline"]
  static values = { baseScore: Number }
  
  connect() {
    this.calculateScore()
  }
  
  calculateScore() {
    const budgetWeight = this.getBudgetWeight()
    const timelineWeight = this.getTimelineWeight()
    const score = (budgetWeight * 0.4 + timelineWeight * 0.6) * 100
    
    this.scoreTarget.textContent = Math.round(score)
  }
  
  getBudgetWeight() {
    const budget = this.budgetTarget.value
    const weights = {
      'enterprise': 1.0,
      'large': 0.85,
      'medium': 0.65,
      'small': 0.35
    }
    return weights[budget] || 0.1
  }
}
```

## 🎨 UI/UX Guidelines

### Design Principles
- **Professional Aesthetics**: Clean, modern design that builds trust
- **Conversion Focus**: Every page should drive toward contact/consultation
- **Mobile-First**: Responsive design with excellent mobile experience
- **Performance**: Fast loading, optimized images and assets
- **Accessibility**: WCAG compliance, semantic HTML, proper contrast

### Component Library
We maintain consistent components for:
- **Cards**: Project showcases, service offerings
- **Forms**: Lead capture, contact forms
- **Navigation**: Headers, breadcrumbs, pagination
- **Metrics**: Business impact displays, statistics
- **Testimonials**: Client feedback presentation

## 🔒 Security Guidelines

### Input Validation
```ruby
# Always use strong parameters
def lead_params
  params.require(:lead).permit(:name, :email, :company, :message)
end

# Validate in models
validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
validates :message, length: { maximum: 1000 }
```

### Rate Limiting
```ruby
# config/application.rb
config.middleware.use Rack::Attack

# Rate limiting rules
Rack::Attack.throttle('req/ip', limit: 300, period: 5.minutes) do |req|
  req.ip
end

Rack::Attack.throttle('contact/ip', limit: 5, period: 1.hour) do |req|
  req.ip if req.path == '/leads' && req.post?
end
```

### Authentication
```ruby
class AdminController < ApplicationController
  before_action :authenticate_admin!
  
  private
  
  def authenticate_admin!
    redirect_to root_path unless current_user&.admin?
  end
end
```

## 📊 Performance Guidelines

### Database Optimization
```ruby
# Use includes to prevent N+1 queries
@projects = Project.includes(:client, :services, :technologies)

# Add appropriate indexes
add_index :leads, :lead_score
add_index :projects, [:status, :featured, :completed_at]

# Use counter caches for expensive counts
belongs_to :client, counter_cache: :projects_count
```

### Caching Strategies
```ruby
# Fragment caching
<% cache [@project, 'v2'] do %>
  <%= render @project %>
<% end %>

# Method caching
def expensive_calculation
  Rails.cache.fetch("project_#{id}_metrics", expires_in: 1.hour) do
    # Expensive calculation
  end
end
```

### Background Jobs
```ruby
class LeadWorkflowJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: 5.seconds, attempts: 3
  
  def perform(lead_id)
    lead = Lead.find(lead_id)
    
    # Process lead asynchronously
    lead.calculate_score
    CrmIntegrationService.new(lead).sync
    LeadNotificationMailer.new_lead(lead).deliver_now
  end
end
```

## 🚀 Deployment Guidelines

### Pre-deployment Checklist
- [ ] All tests passing
- [ ] Security audit completed
- [ ] Performance benchmarks met
- [ ] Database migrations tested
- [ ] Environment variables configured
- [ ] SSL certificates valid
- [ ] Monitoring alerts configured

### Database Migrations
```ruby
class AddLeadScoringToLeads < ActiveRecord::Migration[7.0]
  def change
    add_column :leads, :lead_score, :integer, default: 0
    add_index :leads, :lead_score
    
    # Backfill existing records
    reversible do |dir|
      dir.up do
        Lead.find_each(&:calculate_score)
      end
    end
  end
end
```

## 📈 Monitoring & Analytics

### Performance Monitoring
```ruby
# app/controllers/concerns/performance_tracking.rb
module PerformanceTracking
  extend ActiveSupport::Concern
  
  included do
    around_action :track_performance, if: -> { Rails.env.production? }
  end
  
  private
  
  def track_performance
    start_time = Time.current
    yield
  ensure
    duration = Time.current - start_time
    Rails.logger.info "#{controller_name}##{action_name}: #{duration.round(3)}s"
  end
end
```

### Business Metrics Tracking
```ruby
# Track lead conversion events
class Lead < ApplicationRecord
  after_create :track_creation
  after_update :track_status_change, if: :status_changed?
  
  private
  
  def track_creation
    Analytics.track('Lead Created', {
      source: utm_params['utm_source'],
      score: lead_score,
      budget_range: budget_range
    })
  end
end
```

## 🐛 Bug Reports

### Issue Template
When reporting bugs, include:

1. **Expected Behavior**: What should happen
2. **Actual Behavior**: What actually happens
3. **Steps to Reproduce**: Detailed steps
4. **Environment**: Browser, OS, Ruby version
5. **Screenshots**: If applicable
6. **Error Messages**: Complete stack traces

### Bug Fix Process
1. Create failing test that reproduces bug
2. Implement minimal fix to make test pass
3. Verify fix doesn't break existing functionality
4. Add regression test if necessary

## 🎯 Feature Requests

### Feature Request Template
1. **Business Value**: Why is this feature needed?
2. **User Story**: As a [user], I want [goal] so that [benefit]
3. **Acceptance Criteria**: What defines "done"?
4. **Technical Considerations**: Any implementation notes
5. **Success Metrics**: How to measure success

### Feature Development Process
1. **Discovery**: Research and validate need
2. **Design**: Create mockups and technical spec
3. **Implementation**: TDD development
4. **Testing**: Comprehensive test coverage
5. **Documentation**: Update relevant docs
6. **Deployment**: Feature flags for gradual rollout

## 📚 Resources

### Learning Resources
- [Rails Guides](https://guides.rubyonrails.org/)
- [TailwindCSS Documentation](https://tailwindcss.com/docs)
- [Hotwire Handbook](https://hotwired.dev/)
- [RSpec Documentation](https://rspec.info/)

### Code Review Checklist
- [ ] Tests are comprehensive and passing
- [ ] Code follows style guidelines
- [ ] Performance impact considered
- [ ] Security implications reviewed
- [ ] Documentation updated
- [ ] Error handling implemented
- [ ] Accessibility requirements met

## 💬 Communication

### Getting Help
- **General Questions**: GitHub Discussions
- **Bug Reports**: GitHub Issues
- **Feature Requests**: GitHub Issues with `enhancement` label
- **Security Issues**: Email security@yourcompany.com

### Code Reviews
We value constructive feedback and collaborative development. When reviewing:

- **Be Respectful**: Focus on code, not the person
- **Be Specific**: Provide actionable feedback
- **Be Educational**: Share knowledge and best practices
- **Be Timely**: Review promptly to maintain momentum

## 🏆 Recognition

Contributors who make significant impacts will be:
- Added to the CONTRIBUTORS.md file
- Mentioned in release notes
- Invited to technical discussions and planning

Thank you for contributing to our mission of building a world-class digital agency platform! 

---

## Quick Reference

### Common Commands
```bash
# Development
rails server                    # Start development server
bundle exec rspec              # Run all tests
bundle exec rubocop            # Check code style
bundle audit                   # Security audit

# Testing
rspec spec/models             # Test models only
rspec spec/controllers        # Test controllers only
rspec spec/system            # Test full workflows

# Deployment
docker-compose up --build    # Build and start containers
rails db:migrate RAILS_ENV=production  # Production migration
```

### Key Files
- `README.md`: Project overview and setup
- `PRD.md`: Product requirements document
- `claude.md`: AI development guidelines
- `.env.example`: Environment variables template
- `Gemfile`: Ruby dependencies
- `package.json`: JavaScript dependencies
