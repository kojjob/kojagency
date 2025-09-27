# spec/rails_helper.rb
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'shoulda-matchers'
require 'factory_bot_rails'

# Add additional requires below this line. Rails is not loaded until this point!
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
  
  # Factory Bot configuration
  config.include FactoryBot::Syntax::Methods
  
  # Database cleaner
  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end
  
  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
  
  # System test configuration
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

# spec/factories/projects.rb
FactoryBot.define do
  factory :project do
    title { Faker::Company.bs.titleize }
    description { Faker::Lorem.paragraph(sentence_count: 3) }
    challenge { Faker::Lorem.paragraph(sentence_count: 5) }
    solution { Faker::Lorem.paragraph(sentence_count: 6) }
    results { Faker::Lorem.paragraph(sentence_count: 4) }
    status { 'published' }
    budget_range { 'medium' }
    duration_months { rand(3..18) }
    team_size { rand(2..8) }
    started_at { rand(2.years.ago..6.months.ago) }
    completed_at { rand(3.months.ago..1.week.ago) }
    featured { false }
    
    association :client
    
    after(:build) do |project|
      project.services << build(:service, :web_development) if project.services.empty?
      project.technologies << build(:technology, :rails) if project.technologies.empty?
    end
    
    trait :featured do
      featured { true }
      status { 'featured' }
    end
    
    trait :with_metrics do
      after(:create) do |project|
        create_list(:project_metric, 3, project: project)
      end
    end
    
    trait :with_testimonial do
      after(:create) do |project|
        create(:testimonial, project: project, client: project.client)
      end
    end
  end
end

# spec/factories/clients.rb
FactoryBot.define do
  factory :client do
    name { Faker::Company.name }
    industry { ['SaaS', 'E-commerce', 'Healthcare', 'FinTech', 'Education'].sample }
    company_size { ['startup', 'growth', 'midmarket', 'enterprise'].sample }
    website { Faker::Internet.url }
    description { Faker::Company.bs }
    location { Faker::Address.city }
    founded_year { rand(1990..2020) }
  end
end

# spec/factories/services.rb
FactoryBot.define do
  factory :service do
    name { "Custom Service" }
    description { Faker::Lorem.sentence(word_count: 10) }
    full_description { Faker::Lorem.paragraph(sentence_count: 5) }
    category { 'web' }
    status { 'active' }
    featured { true }
    base_price { rand(10000..100000) }
    typical_duration_weeks { rand(8..24) }
    
    trait :web_development do
      name { 'Web Development' }
      category { 'web' }
      description { 'Custom web applications built with modern frameworks' }
    end
    
    trait :mobile_development do
      name { 'Mobile Development' }
      category { 'mobile' }
      description { 'Native iOS and Android applications' }
    end
    
    trait :data_analytics do
      name { 'Data Analytics' }
      category { 'data' }
      description { 'Custom dashboards and data visualization systems' }
    end
  end
end

# spec/factories/technologies.rb
FactoryBot.define do
  factory :technology do
    name { 'Generic Tech' }
    category { 'backend' }
    proficiency_level { 'advanced' }
    color_hex { '#6B7280' }
    
    trait :rails do
      name { 'Ruby on Rails' }
      category { 'backend' }
      proficiency_level { 'expert' }
      color_hex { '#CC0000' }
    end
    
    trait :react do
      name { 'React' }
      category { 'frontend' }
      proficiency_level { 'expert' }
      color_hex { '#61DAFB' }
    end
  end
end

# spec/factories/leads.rb
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
      lead_score { 85 }
    end
    
    trait :qualified do
      status { 'qualified' }
      qualified_at { 1.day.ago }
    end
  end
end

# spec/models/project_spec.rb
require 'rails_helper'

RSpec.describe Project, type: :model do
  describe 'associations' do
    it { should belong_to(:client) }
    it { should have_many(:project_technologies).dependent(:destroy) }
    it { should have_many(:technologies).through(:project_technologies) }
    it { should have_many(:project_services).dependent(:destroy) }
    it { should have_many(:services).through(:project_services) }
    it { should have_many(:project_metrics).dependent(:destroy) }
    it { should have_many_attached(:images) }
  end
  
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(100) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:challenge) }
    it { should validate_presence_of(:solution) }
    it { should validate_presence_of(:results) }
    it { should validate_presence_of(:duration_months) }
    it { should validate_numericality_of(:duration_months).is_greater_than(0) }
  end
  
  describe 'scopes' do
    let!(:published_project) { create(:project, status: 'published') }
    let!(:featured_project) { create(:project, :featured) }
    let!(:draft_project) { create(:project, status: 'draft') }
    
    it 'returns published projects' do
      expect(Project.published).to include(published_project)
      expect(Project.published).not_to include(draft_project)
    end
    
    it 'returns featured projects' do
      expect(Project.featured).to include(featured_project)
      expect(Project.featured).not_to include(published_project)
    end
  end
  
  describe '#roi_percentage' do
    context 'with investment and return amounts' do
      let(:project) do
        create(:project, investment_amount: 50000, return_amount: 125000)
      end
      
      it 'calculates ROI percentage correctly' do
        expect(project.roi_percentage).to eq(150.0)
      end
    end
    
    context 'without investment amount' do
      let(:project) { create(:project, investment_amount: nil) }
      
      it 'returns nil' do
        expect(project.roi_percentage).to be_nil
      end
    end
  end
  
  describe '#primary_service' do
    let(:project) { create(:project) }
    let(:web_service) { create(:service, :web_development) }
    let(:mobile_service) { create(:service, :mobile_development) }
    
    before do
      project.services << [web_service, mobile_service]
    end
    
    it 'returns the first service' do
      expect(project.primary_service).to eq(web_service)
    end
  end
end

# spec/models/lead_spec.rb
require 'rails_helper'

RSpec.describe Lead, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_length_of(:name).is_at_most(100) }
    it { should allow_value('test@example.com').for(:email) }
    it { should_not allow_value('invalid-email').for(:email) }
  end
  
  describe 'scopes' do
    let!(:new_lead) { create(:lead, status: 'new') }
    let!(:contacted_lead) { create(:lead, status: 'contacted') }
    let!(:this_month_lead) { create(:lead, created_at: 2.weeks.ago) }
    let!(:old_lead) { create(:lead, created_at: 2.months.ago) }
    
    it 'returns new leads' do
      expect(Lead.new_leads).to include(new_lead)
      expect(Lead.new_leads).not_to include(contacted_lead)
    end
    
    it 'returns leads from this month' do
      expect(Lead.this_month).to include(this_month_lead)
      expect(Lead.this_month).not_to include(old_lead)
    end
  end
  
  describe '#calculate_score' do
    let(:lead) do
      create(:lead,
        budget_range: 'enterprise',
        timeline: 'asap',
        project_type: 'data',
        company: 'Tech Corp',
        phone: '+1234567890',
        message: 'We need a comprehensive data analytics platform for our growing business needs.'
      )
    end
    
    it 'calculates and updates the lead score' do
      expect { lead.calculate_score }.to change { lead.lead_score }.from(0)
      expect(lead.lead_score).to be > 70 # High-quality lead
    end
  end
  
  describe 'lead scoring algorithm' do
    context 'high-value lead' do
      let(:lead) { build(:lead, :high_score) }
      
      it 'assigns high score for enterprise budget + urgent timeline + complex project' do
        lead.calculate_score
        expect(lead.lead_score).to be >= 80
      end
    end
    
    context 'low-value lead' do
      let(:lead) do
        build(:lead,
          budget_range: 'small',
          timeline: 'year',
          project_type: 'other',
          company: nil,
          phone: nil,
          message: 'Hi'
        )
      end
      
      it 'assigns low score for small budget + distant timeline + vague project' do
        lead.calculate_score
        expect(lead.lead_score).to be <= 30
      end
    end
  end
end

# spec/services/lead_scoring_service_spec.rb
require 'rails_helper'

RSpec.describe LeadScoringService, type: :service do
  let(:service) { described_class.new(lead) }
  
  describe '#calculate_score' do
    context 'with high-value lead characteristics' do
      let(:lead) do
        build(:lead,
          budget_range: 'enterprise',
          timeline: 'asap',
          project_type: 'data',
          company: 'Enterprise Corp',
          phone: '+1234567890',
          email: 'cto@enterprise.com',
          message: 'We need a comprehensive data analytics solution to process our customer data and generate real-time insights for our executive team. Timeline is critical as we launch our new product line.'
        )
      end
      
      it 'returns a high score' do
        score = service.calculate_score
        expect(score).to be >= 80
      end
    end
    
    context 'with medium-value lead characteristics' do
      let(:lead) do
        build(:lead,
          budget_range: 'medium',
          timeline: 'quarter',
          project_type: 'web',
          company: 'Growing Startup',
          phone: nil,
          email: 'founder@startup.com',
          message: 'Looking to build a web application for our business.'
        )
      end
      
      it 'returns a medium score' do
        score = service.calculate_score
        expect(score).to be_between(40, 79)
      end
    end
    
    context 'with low-value lead characteristics' do
      let(:lead) do
        build(:lead,
          budget_range: 'small',
          timeline: 'year',
          project_type: 'other',
          company: nil,
          phone: nil,
          email: 'test@gmail.com',
          message: 'I need some help with a project'
        )
      end
      
      it 'returns a low score' do
        score = service.calculate_score
        expect(score).to be <= 40
      end
    end
  end
end

# spec/controllers/projects_controller_spec.rb
require 'rails_helper'

RSpec.describe ProjectsController, type: :controller do
  describe 'GET #index' do
    let!(:published_projects) { create_list(:project, 3, status: 'published') }
    let!(:draft_project) { create(:project, status: 'draft') }
    
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end
    
    it 'loads only published projects' do
      get :index
      expect(assigns(:projects)).to match_array(published_projects)
      expect(assigns(:projects)).not_to include(draft_project)
    end
    
    context 'with service filter' do
      let(:web_service) { create(:service, :web_development) }
      let!(:web_project) { create(:project, services: [web_service]) }
      
      it 'filters projects by service' do
        get :index, params: { service_id: web_service.id }
        expect(assigns(:projects)).to include(web_project)
      end
    end
  end
  
  describe 'GET #show' do
    let(:project) { create(:project, :featured, :with_metrics, :with_testimonial) }
    
    it 'returns a successful response' do
      get :show, params: { id: project.slug }
      expect(response).to be_successful
    end
    
    it 'loads the project' do
      get :show, params: { id: project.slug }
      expect(assigns(:project)).to eq(project)
    end
    
    it 'loads related projects' do
      related_project = create(:project, services: project.services)
      get :show, params: { id: project.slug }
      expect(assigns(:related_projects)).to include(related_project)
    end
    
    context 'with invalid project slug' do
      it 'redirects to index with error' do
        get :show, params: { id: 'non-existent-project' }
        expect(response).to redirect_to(projects_path)
        expect(flash[:alert]).to eq('Project not found.')
      end
    end
  end
end

# spec/controllers/leads_controller_spec.rb
require 'rails_helper'

RSpec.describe LeadsController, type: :controller do
  describe 'POST #create' do
    let(:valid_attributes) do
      {
        name: 'John Doe',
        email: 'john@example.com',
        company: 'Test Corp',
        project_type: 'web',
        budget_range: 'medium',
        timeline: 'quarter',
        message: 'We need a new website for our business.'
      }
    end
    
    context 'with valid parameters' do
      it 'creates a new lead' do
        expect {
          post :create, params: { lead: valid_attributes }
        }.to change(Lead, :count).by(1)
      end
      
      it 'calculates the lead score' do
        post :create, params: { lead: valid_attributes }
        lead = Lead.last
        expect(lead.lead_score).to be > 0
      end
      
      it 'triggers the workflow job' do
        expect(LeadWorkflowJob).to receive(:perform_async)
        post :create, params: { lead: valid_attributes }
      end
      
      it 'redirects with success message' do
        post :create, params: { lead: valid_attributes }
        expect(response).to redirect_to(root_path(anchor: 'contact'))
        expect(flash[:notice]).to match(/thank you/i)
      end
    end
    
    context 'with invalid parameters' do
      let(:invalid_attributes) { { name: '', email: 'invalid-email' } }
      
      it 'does not create a new lead' do
        expect {
          post :create, params: { lead: invalid_attributes }
        }.not_to change(Lead, :count)
      end
      
      it 'redirects with error message' do
        post :create, params: { lead: invalid_attributes }
        expect(response).to redirect_to(root_path(anchor: 'contact'))
        expect(flash[:alert]).to be_present
      end
    end
    
    context 'JSON request' do
      it 'returns JSON response for valid lead' do
        post :create, params: { lead: valid_attributes }, format: :json
        expect(response).to have_http_status(:success)
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['lead_id']).to be_present
        expect(json_response['score']).to be > 0
      end
    end
  end
end

# spec/system/project_filtering_spec.rb
require 'rails_helper'

RSpec.describe 'Project Filtering', type: :system, js: true do
  let!(:web_service) { create(:service, :web_development) }
  let!(:mobile_service) { create(:service, :mobile_development) }
  let!(:rails_tech) { create(:technology, :rails) }
  let!(:react_tech) { create(:technology, :react) }
  
  let!(:web_project) do
    create(:project, :featured, 
      title: 'E-commerce Platform',
      services: [web_service],
      technologies: [rails_tech, react_tech]
    )
  end
  
  let!(:mobile_project) do
    create(:project,
      title: 'Mobile Banking App', 
      services: [mobile_service],
      technologies: [react_tech]
    )
  end
  
  before do
    visit projects_path
  end
  
  it 'filters projects by service' do
    expect(page).to have_content('E-commerce Platform')
    expect(page).to have_content('Mobile Banking App')
    
    click_link 'Web Development'
    
    expect(page).to have_content('E-commerce Platform')
    expect(page).not_to have_content('Mobile Banking App')
  end
  
  it 'filters projects by technology' do
    click_link 'Ruby on Rails'
    
    expect(page).to have_content('E-commerce Platform')
    expect(page).not_to have_content('Mobile Banking App')
  end
  
  it 'shows all projects when All filter is selected' do
    click_link 'Web Development'
    expect(page).not_to have_content('Mobile Banking App')
    
    click_link 'All', match: :first
    
    expect(page).to have_content('E-commerce Platform')
    expect(page).to have_content('Mobile Banking App')
  end
end

# spec/system/lead_submission_spec.rb  
require 'rails_helper'

RSpec.describe 'Lead Submission', type: :system do
  before do
    visit root_path
  end
  
  it 'successfully submits a lead form' do
    scroll_to(find('#contact'))
    
    fill_in 'Name', with: 'Jane Smith'
    fill_in 'Email', with: 'jane@example.com'
    fill_in 'Company', with: 'Tech Startup Inc'
    select '$25k - $100k', from: 'Budget Range'
    check 'Web App'
    check 'Data Analytics'
    fill_in 'Tell us about your project', with: 'We need a comprehensive web application with real-time analytics for our growing user base.'
    
    click_button 'Get Free Project Estimate'
    
    expect(page).to have_content('Thank you')
    expect(Lead.last.name).to eq('Jane Smith')
    expect(Lead.last.lead_score).to be > 0
  end
  
  it 'shows validation errors for incomplete form' do
    scroll_to(find('#contact'))
    
    click_button 'Get Free Project Estimate'
    
    expect(page).to have_content('error')
  end
end

# spec/jobs/lead_workflow_job_spec.rb
require 'rails_helper'

RSpec.describe LeadWorkflowJob, type: :job do
  let(:lead) { create(:lead, :high_score) }
  
  describe '#perform' do
    it 'creates lead activity' do
      expect {
        described_class.new.perform(lead.id)
      }.to change(LeadActivity, :count).by(1)
      
      activity = LeadActivity.last
      expect(activity.lead).to eq(lead)
      expect(activity.activity_type).to eq('created')
    end
    
    it 'sends notification for high-score leads' do
      expect(LeadNotificationMailer).to receive_message_chain(:new_lead, :deliver_now)
      described_class.new.perform(lead.id)
    end
    
    it 'schedules appropriate follow-up based on score' do
      expect(AdminNotificationJob).to receive(:perform_now).with(lead.id, 'high_priority_lead')
      described_class.new.perform(lead.id)
    end
  end
end

# spec/integration/api/v1/leads_spec.rb
require 'rails_helper'

RSpec.describe 'API V1 Leads', type: :request do
  describe 'POST /api/v1/leads' do
    let(:valid_attributes) do
      {
        lead: {
          name: 'API Test User',
          email: 'api@test.com',
          company: 'API Corp',
          project_type: 'web',
          budget_range: 'large',
          timeline: 'month',
          message: 'API submitted lead for testing'
        }
      }
    end
    
    context 'with valid parameters' do
      it 'creates a new lead' do
        expect {
          post '/api/v1/leads', params: valid_attributes, as: :json
        }.to change(Lead, :count).by(1)
        
        expect(response).to have_http_status(:created)
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be true
        expect(json_response['lead']['score']).to be > 0
      end
    end
    
    context 'with invalid parameters' do
      let(:invalid_attributes) do
        { lead: { name: '', email: 'invalid' } }
      end
      
      it 'returns validation errors' do
        post '/api/v1/leads', params: invalid_attributes, as: :json
        
        expect(response).to have_http_status(:unprocessable_entity)
        
        json_response = JSON.parse(response.body)
        expect(json_response['success']).to be false
        expect(json_response['errors']).to be_present
      end
    end
  end
end

# Test configuration files
# spec/support/database_cleaner.rb
require 'database_cleaner'

RSpec.configure do |config|
  config.before(:suite) do
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

# spec/support/capybara.rb
require 'capybara/rails'
require 'capybara/rspec'
require 'selenium-webdriver'

Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--window-size=1400,1400')

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options
  )
end

Capybara.javascript_driver = :selenium_chrome_headless
Capybara.default_max_wait_time = 10

# Custom test helpers
# spec/support/lead_helpers.rb
module LeadHelpers
  def score_color(score)
    return 'bg-green-500' if score >= 80
    return 'bg-yellow-500' if score >= 60
    return 'bg-orange-500' if score >= 40
    'bg-red-500'
  end
  
  def score_label(score)
    return 'High Priority' if score >= 80
    return 'Medium Priority' if score >= 60
    return 'Low Priority' if score >= 40
    'Very Low'
  end
  
  def status_color(status)
    case status
    when 'new' then 'bg-blue-100 text-blue-800'
    when 'contacted' then 'bg-yellow-100 text-yellow-800'
    when 'qualified' then 'bg-green-100 text-green-800'
    when 'proposal' then 'bg-purple-100 text-purple-800'
    when 'closed' then 'bg-gray-100 text-gray-800'
    else 'bg-gray-100 text-gray-800'
    end
  end
end

RSpec.configure do |config|
  config.include LeadHelpers, type: :view
  config.include LeadHelpers, type: :system
end