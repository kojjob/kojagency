# app/controllers/projects_controller.rb
class ProjectsController < ApplicationController
  before_action :set_project, only: [:show]
  
  def index
    @projects = Project.published.includes(:client, :services, :technologies, :project_metrics)
    
    # Filter by service if specified
    if params[:service_id].present?
      service = Service.find(params[:service_id])
      @projects = @projects.by_service(service)
    end
    
    # Filter by technology if specified
    if params[:technology_id].present?
      @projects = @projects.joins(:technologies).where(technologies: { id: params[:technology_id] })
    end
    
    # Filter by budget range if specified
    if params[:budget_range].present?
      @projects = @projects.where(budget_range: params[:budget_range])
    end
    
    @projects = @projects.recent.includes(:testimonials)
    @services = Service.active.featured
    @technologies = Technology.popular.limit(10)
    
    respond_to do |format|
      format.html
      format.turbo_stream # For Hotwire filtering
    end
  end
  
  def show
    @related_projects = Project.published
                              .where.not(id: @project.id)
                              .joins(:services)
                              .where(services: { id: @project.services.pluck(:id) })
                              .limit(3)
                              .includes(:client, :services, :technologies)
  end
  
  private
  
  def set_project
    @project = Project.published.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to projects_path, alert: "Project not found."
  end
end

# app/controllers/admin/projects_controller.rb
class Admin::ProjectsController < AdminController
  before_action :set_project, only: [:show, :edit, :update, :destroy]
  
  def index
    @projects = Project.includes(:client, :services, :technologies)
                      .order(updated_at: :desc)
                      .page(params[:page])
    
    if params[:status].present?
      @projects = @projects.where(status: params[:status])
    end
    
    if params[:search].present?
      @projects = @projects.where(
        "title ILIKE ? OR description ILIKE ?", 
        "%#{params[:search]}%", "%#{params[:search]}%"
      )
    end
  end
  
  def show
  end
  
  def new
    @project = Project.new
    @clients = Client.all.order(:name)
    @services = Service.active.order(:name)
    @technologies = Technology.all.order(:name)
  end
  
  def create
    @project = Project.new(project_params)
    
    if @project.save
      redirect_to admin_project_path(@project), notice: 'Project created successfully.'
    else
      @clients = Client.all.order(:name)
      @services = Service.active.order(:name)
      @technologies = Technology.all.order(:name)
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    @clients = Client.all.order(:name)
    @services = Service.active.order(:name)
    @technologies = Technology.all.order(:name)
  end
  
  def update
    if @project.update(project_params)
      redirect_to admin_project_path(@project), notice: 'Project updated successfully.'
    else
      @clients = Client.all.order(:name)
      @services = Service.active.order(:name)
      @technologies = Technology.all.order(:name)
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    @project.destroy!
    redirect_to admin_projects_path, notice: 'Project deleted successfully.'
  end
  
  private
  
  def set_project
    @project = Project.friendly.find(params[:id])
  end
  
  def project_params
    params.require(:project).permit(
      :title, :description, :challenge, :solution, :results, 
      :status, :budget_range, :duration_months, :team_size,
      :started_at, :completed_at, :project_url, :github_url,
      :investment_amount, :return_amount, :featured, :client_id,
      service_ids: [], technology_ids: [], images: []
    )
  end
end

# app/views/projects/index.html.erb
<% content_for :title, "Our Work - Case Studies" %>
<% content_for :meta_description, "Explore our portfolio of successful web, mobile, and data analytics projects. See real results and business impact." %>

<div class="bg-white">
  <!-- Hero Section -->
  <div class="bg-gradient-to-br from-primary-50 to-secondary-50 py-16">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="text-center">
        <h1 class="text-4xl md:text-5xl font-bold text-gray-900 mb-4">
          Our Work
        </h1>
        <p class="text-xl text-gray-600 max-w-3xl mx-auto">
          Real projects, real results. Explore how we've helped businesses scale with 
          custom web applications, mobile apps, and data analytics platforms.
        </p>
      </div>
    </div>
  </div>

  <!-- Filters Section -->
  <div class="bg-white border-b border-gray-200 sticky top-16 z-40">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="py-6">
        <%= turbo_frame_tag "project_filters", class: "space-y-4" do %>
          <div data-controller="filter" data-filter-url-value="<%= projects_path %>">
            <!-- Service Filters -->
            <div class="flex flex-wrap items-center gap-3 mb-4">
              <span class="text-sm font-medium text-gray-700">Services:</span>
              <%= link_to "All", projects_path, 
                  class: "px-4 py-2 rounded-full text-sm font-medium transition-colors #{'bg-primary-100 text-primary-800' if params[:service_id].blank?} #{'bg-gray-100 text-gray-700 hover:bg-gray-200' if params[:service_id].present?}",
                  data: { action: "click->filter#updateFilter", filter_param: "service_id", filter_value: "" } %>
              
              <% @services.each do |service| %>
                <%= link_to service.name, projects_path(service_id: service.id), 
                    class: "px-4 py-2 rounded-full text-sm font-medium transition-colors #{params[:service_id] == service.id.to_s ? 'bg-primary-100 text-primary-800' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'}",
                    data: { action: "click->filter#updateFilter", filter_param: "service_id", filter_value: service.id } %>
              <% end %>
            </div>
            
            <!-- Technology Filters -->
            <div class="flex flex-wrap items-center gap-3">
              <span class="text-sm font-medium text-gray-700">Technologies:</span>
              <%= link_to "All", projects_path, 
                  class: "px-4 py-2 rounded-full text-sm font-medium transition-colors #{'bg-secondary-100 text-secondary-800' if params[:technology_id].blank?} #{'bg-gray-100 text-gray-700 hover:bg-gray-200' if params[:technology_id].present?}",
                  data: { action: "click->filter#updateFilter", filter_param: "technology_id", filter_value: "" } %>
              
              <% @technologies.each do |technology| %>
                <%= link_to technology.name, projects_path(technology_id: technology.id), 
                    class: "px-4 py-2 rounded-full text-sm font-medium transition-colors #{params[:technology_id] == technology.id.to_s ? 'bg-secondary-100 text-secondary-800' : 'bg-gray-100 text-gray-700 hover:bg-gray-200'}",
                    data: { action: "click->filter#updateFilter", filter_param: "technology_id", filter_value: technology.id } %>
              <% end %>
            </div>
          </div>
        <% end %>
      </div>
    </div>
  </div>

  <!-- Projects Grid -->
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
    <%= turbo_frame_tag "projects_grid" do %>
      <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-8" data-controller="project-grid">
        <% @projects.each_with_index do |project, index| %>
          <div class="bg-white rounded-xl shadow-lg hover:shadow-2xl transition-all duration-300 overflow-hidden group"
               data-project-grid-target="card"
               data-index="<%= index %>"
               style="animation-delay: <%= index * 0.1 %>s">
            
            <!-- Project Image -->
            <div class="aspect-video bg-gradient-to-br from-primary-100 to-secondary-100 relative overflow-hidden">
              <% if project.images.attached? %>
                <%= image_tag project.images.first, 
                    class: "w-full h-full object-cover group-hover:scale-105 transition-transform duration-300",
                    alt: project.title %>
              <% else %>
                <div class="flex items-center justify-center h-full">
                  <div class="text-center">
                    <div class="w-16 h-16 bg-primary-500 rounded-full mx-auto mb-4 flex items-center justify-center">
                      <svg class="w-8 h-8 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/>
                      </svg>
                    </div>
                    <div class="text-gray-600 text-sm">Project Preview</div>
                  </div>
                </div>
              <% end %>
              
              <!-- Service Badge -->
              <div class="absolute top-4 left-4">
                <span class="px-3 py-1 bg-white/90 backdrop-blur-sm text-primary-600 rounded-full text-xs font-medium">
                  <%= project.primary_service&.name || "Custom Project" %>
                </span>
              </div>
              
              <!-- Featured Badge -->
              <% if project.featured? %>
                <div class="absolute top-4 right-4">
                  <span class="px-3 py-1 bg-secondary-500 text-white rounded-full text-xs font-medium">
                    Featured
                  </span>
                </div>
              <% end %>
            </div>
            
            <!-- Project Details -->
            <div class="p-6">
              <div class="mb-4">
                <h3 class="text-xl font-bold text-gray-900 mb-2 group-hover:text-primary-600 transition-colors">
                  <%= link_to project.title, project_path(project), class: "hover:underline" %>
                </h3>
                <p class="text-gray-600 text-sm leading-relaxed line-clamp-3">
                  <%= project.description %>
                </p>
              </div>
              
              <!-- Client Info -->
              <div class="flex items-center mb-4">
                <div class="w-8 h-8 bg-gray-200 rounded-full flex items-center justify-center mr-3">
                  <span class="text-xs font-medium text-gray-600">
                    <%= project.client.name.first.upcase %>
                  </span>
                </div>
                <div>
                  <div class="text-sm font-medium text-gray-900"><%= project.client.name %></div>
                  <div class="text-xs text-gray-500"><%= project.client.industry %></div>
                </div>
              </div>
              
              <!-- Metrics -->
              <% if project.project_metrics.any? %>
                <div class="grid grid-cols-2 gap-4 mb-4">
                  <% project.project_metrics.limit(2).each do |metric| %>
                    <div class="text-center p-3 bg-gray-50 rounded-lg">
                      <div class="text-lg font-bold text-primary-600">
                        <% if metric.improvement_percentage > 0 %>
                          +<%= metric.improvement_percentage %>%
                        <% else %>
                          <%= metric.after_value %><%= metric.unit %>
                        <% end %>
                      </div>
                      <div class="text-xs text-gray-600"><%= metric.metric_name %></div>
                    </div>
                  <% end %>
                </div>
              <% end %>
              
              <!-- Tech Stack -->
              <div class="flex flex-wrap gap-2 mb-4">
                <% project.technologies.limit(3).each do |technology| %>
                  <span class="px-2 py-1 bg-gray-100 text-gray-700 rounded text-xs">
                    <%= technology.name %>
                  </span>
                <% end %>
                <% if project.technologies.count > 3 %>
                  <span class="px-2 py-1 bg-gray-100 text-gray-700 rounded text-xs">
                    +<%= project.technologies.count - 3 %> more
                  </span>
                <% end %>
              </div>
              
              <!-- CTA -->
              <div class="flex items-center justify-between">
                <%= link_to "View Case Study", project_path(project), 
                    class: "text-primary-600 hover:text-primary-700 font-medium text-sm flex items-center" %>
                <div class="text-xs text-gray-500">
                  <%= project.duration_months %> months
                </div>
              </div>
            </div>
          </div>
        <% end %>
      </div>
      
      <!-- Empty State -->
      <% if @projects.empty? %>
        <div class="text-center py-12">
          <div class="w-16 h-16 bg-gray-200 rounded-full mx-auto mb-4 flex items-center justify-center">
            <svg class="w-8 h-8 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z"/>
            </svg>
          </div>
          <h3 class="text-lg font-medium text-gray-900 mb-2">No projects found</h3>
          <p class="text-gray-600 mb-6">Try adjusting your filters to see more results.</p>
          <%= link_to "View All Projects", projects_path, 
              class: "text-primary-600 hover:text-primary-700 font-medium" %>
        </div>
      <% end %>
    <% end %>
  </div>
</div>

# app/views/projects/show.html.erb  
<% content_for :title, @project.title %>
<% content_for :meta_description, truncate(@project.description, length: 160) %>

<div class="bg-white">
  <!-- Hero Section -->
  <div class="relative bg-gradient-to-br from-primary-50 to-secondary-50 py-20">
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
      <div class="grid lg:grid-cols-2 gap-12 items-center">
        <div>
          <div class="flex items-center space-x-4 mb-6">
            <%= link_to projects_path, 
                class: "flex items-center text-primary-600 hover:text-primary-700 text-sm font-medium" do %>
              <svg class="w-4 h-4 mr-1" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10 19l-7-7m0 0l7-7m-7 7h18"/>
              </svg>
              Back to Projects
            <% end %>
            
            <% if @project.featured? %>
              <span class="px-3 py-1 bg-secondary-500 text-white rounded-full text-xs font-medium">
                Featured
              </span>
            <% end %>
          </div>
          
          <h1 class="text-4xl lg:text-5xl font-bold text-gray-900 mb-6">
            <%= @project.title %>
          </h1>
          
          <p class="text-xl text-gray-600 mb-8 leading-relaxed">
            <%= @project.description %>
          </p>
          
          <!-- Client & Project Info -->
          <div class="grid grid-cols-2 gap-6 mb-8">
            <div>
              <div class="text-sm font-medium text-gray-500 mb-2">Client</div>
              <div class="flex items-center">
                <div class="w-10 h-10 bg-gray-200 rounded-full flex items-center justify-center mr-3">
                  <span class="text-sm font-medium text-gray-600">
                    <%= @project.client.name.first.upcase %>
                  </span>
                </div>
                <div>
                  <div class="font-medium text-gray-900"><%= @project.client.name %></div>
                  <div class="text-sm text-gray-600"><%= @project.client.industry %></div>
                </div>
              </div>
            </div>
            
            <div>
              <div class="text-sm font-medium text-gray-500 mb-2">Duration</div>
              <div class="text-lg font-medium text-gray-900">
                <%= @project.duration_months %> months
              </div>
              <div class="text-sm text-gray-600">
                <%= @project.team_size %> team members
              </div>
            </div>
          </div>
          
          <!-- Quick Metrics -->
          <% if @project.project_metrics.any? %>
            <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
              <% @project.project_metrics.limit(4).each do |metric| %>
                <div class="text-center p-4 bg-white rounded-lg shadow-sm border">
                  <div class="text-2xl font-bold text-primary-600">
                    <% if metric.improvement_percentage != 0 %>
                      <%= metric.improvement_percentage > 0 ? "+" : "" %><%= metric.improvement_percentage %>%
                    <% else %>
                      <%= metric.after_value %><%= metric.unit %>
                    <% end %>
                  </div>
                  <div class="text-sm text-gray-600 mt-1"><%= metric.metric_name %></div>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
        
        <!-- Project Visual -->
        <div class="relative">
          <% if @project.images.attached? %>
            <div class="aspect-video rounded-xl overflow-hidden shadow-2xl">
              <%= image_tag @project.images.first, 
                  class: "w-full h-full object-cover",
                  alt: @project.title %>
            </div>
          <% else %>
            <div class="aspect-video bg-gradient-to-br from-primary-100 to-secondary-100 rounded-xl flex items-center justify-center shadow-2xl">
              <div class="text-center">
                <div class="w-20 h-20 bg-primary-500 rounded-full mx-auto mb-6 flex items-center justify-center">
                  <svg class="w-10 h-10 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11H5m14 0a2 2 0 012 2v6a2 2 0 01-2 2H5a2 2 0 01-2-2v-6a2 2 0 012-2m14 0V9a2 2 0 00-2-2M5 9a2 2 0 012-2m0 0V5a2 2 0 012-2h6a2 2 0 012 2v2M7 7h10"/>
                  </svg>
                </div>
                <div class="text-gray-600">Project Showcase</div>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
  </div>
  
  <!-- Project Details -->
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
    <div class="grid lg:grid-cols-3 gap-12">
      <!-- Main Content -->
      <div class="lg:col-span-2 space-y-12">
        <!-- Challenge -->
        <div>
          <h2 class="text-3xl font-bold text-gray-900 mb-6">The Challenge</h2>
          <div class="prose prose-lg text-gray-700 leading-relaxed">
            <%= simple_format(@project.challenge) %>
          </div>
        </div>
        
        <!-- Solution -->
        <div>
          <h2 class="text-3xl font-bold text-gray-900 mb-6">Our Solution</h2>
          <div class="prose prose-lg text-gray-700 leading-relaxed">
            <%= simple_format(@project.solution) %>
          </div>
        </div>
        
        <!-- Results -->
        <div>
          <h2 class="text-3xl font-bold text-gray-900 mb-6">Results & Impact</h2>
          <div class="prose prose-lg text-gray-700 leading-relaxed mb-8">
            <%= simple_format(@project.results) %>
          </div>
          
          <!-- Detailed Metrics -->
          <% if @project.project_metrics.any? %>
            <div class="grid md:grid-cols-2 gap-6">
              <% @project.project_metrics.each do |metric| %>
                <div class="bg-gray-50 rounded-xl p-6">
                  <div class="flex items-center justify-between mb-4">
                    <h3 class="font-semibold text-gray-900"><%= metric.metric_name %></h3>
                    <span class="px-3 py-1 bg-primary-100 text-primary-800 rounded-full text-sm font-medium">
                      <%= metric.metric_type.humanize %>
                    </span>
                  </div>
                  
                  <div class="flex items-center justify-between mb-2">
                    <span class="text-sm text-gray-600">Before</span>
                    <span class="font-medium text-gray-900">
                      <%= metric.before_value %><%= metric.unit %>
                    </span>
                  </div>
                  
                  <div class="flex items-center justify-between mb-4">
                    <span class="text-sm text-gray-600">After</span>
                    <span class="font-medium text-gray-900">
                      <%= metric.after_value %><%= metric.unit %>
                    </span>
                  </div>
                  
                  <div class="text-center">
                    <div class="text-2xl font-bold <%= metric.improvement_percentage > 0 ? 'text-secondary-600' : 'text-primary-600' %>">
                      <%= metric.improvement_percentage > 0 ? "+" : "" %><%= metric.improvement_percentage %>%
                    </div>
                    <div class="text-sm text-gray-600">Improvement</div>
                  </div>
                </div>
              <% end %>
            </div>
          <% end %>
        </div>
      </div>
      
      <!-- Sidebar -->
      <div class="space-y-8">
        <!-- Tech Stack -->
        <div class="bg-white rounded-xl shadow-lg p-6">
          <h3 class="text-xl font-bold text-gray-900 mb-4">Technology Stack</h3>
          <div class="space-y-3">
            <% @project.technologies.group_by(&:category).each do |category, technologies| %>
              <div>
                <div class="text-sm font-medium text-gray-500 mb-2"><%= category.humanize %></div>
                <div class="flex flex-wrap gap-2">
                  <% technologies.each do |technology| %>
                    <span class="px-3 py-1 bg-gray-100 text-gray-800 rounded-full text-sm font-medium">
                      <%= technology.name %>
                    </span>
                  <% end %>
                </div>
              </div>
            <% end %>
          </div>
        </div>
        
        <!-- Services -->
        <div class="bg-white rounded-xl shadow-lg p-6">
          <h3 class="text-xl font-bold text-gray-900 mb-4">Services Provided</h3>
          <div class="space-y-3">
            <% @project.services.each do |service| %>
              <div class="flex items-center">
                <svg class="w-5 h-5 text-primary-500 mr-3" fill="currentColor" viewBox="0 0 20 20">
                  <path fill-rule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clip-rule="evenodd"/>
                </svg>
                <span class="font-medium text-gray-900"><%= service.name %></span>
              </div>
            <% end %>
          </div>
        </div>
        
        <!-- Testimonial -->
        <% if @project.testimonials.published.any? %>
          <% testimonial = @project.testimonials.published.first %>
          <div class="bg-primary-50 rounded-xl p-6">
            <div class="flex items-center mb-4">
              <% 5.times do |i| %>
                <svg class="w-5 h-5 <%= i < testimonial.rating ? 'text-yellow-400' : 'text-gray-300' %>" fill="currentColor" viewBox="0 0 20 20">
                  <path d="M9.049 2.927c.3-.921 1.603-.921 1.902 0l1.07 3.292a1 1 0 00.95.69h3.462c.969 0 1.371 1.24.588 1.81l-2.8 2.034a1 1 0 00-.364 1.118l1.07 3.292c.3.921-.755 1.688-1.54 1.118l-2.8-2.034a1 1 0 00-1.175 0l-2.8 2.034c-.784.57-1.838-.197-1.539-1.118l1.07-3.292a1 1 0 00-.364-1.118L2.98 8.72c-.783-.57-.38-1.81.588-1.81h3.461a1 1 0 00.951-.69l1.07-3.292z"/>
                </svg>
              <% end %>
            </div>
            
            <blockquote class="text-gray-800 mb-4 leading-relaxed">
              "<%= testimonial.content %>"
            </blockquote>
            
            <div class="flex items-center">
              <div class="w-10 h-10 bg-primary-500 rounded-full flex items-center justify-center mr-3">
                <span class="text-white text-sm font-medium">
                  <%= testimonial.author_name.split(' ').map(&:first).join('') %>
                </span>
              </div>
              <div>
                <div class="font-medium text-gray-900"><%= testimonial.author_name %></div>
                <div class="text-sm text-gray-600"><%= testimonial.author_title %></div>
              </div>
            </div>
          </div>
        <% end %>
        
        <!-- CTA -->
        <div class="bg-primary-600 rounded-xl p-6 text-center text-white">
          <h3 class="text-xl font-bold mb-3">Ready for Similar Results?</h3>
          <p class="text-primary-100 mb-6">
            Let's discuss how we can help scale your business with a custom solution.
          </p>
          <%= link_to "Start Your Project", root_path(anchor: 'contact'), 
              class: "bg-white text-primary-600 px-6 py-3 rounded-lg font-semibold hover:bg-primary-50 transition-colors inline-block" %>
        </div>
      </div>
    </div>
  </div>
  
  <!-- Related Projects -->
  <% if @related_projects.any? %>
    <div class="bg-gray-50 py-16">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="text-center mb-12">
          <h2 class="text-3xl font-bold text-gray-900 mb-4">Related Projects</h2>
          <p class="text-lg text-gray-600">Explore more projects in similar domains</p>
        </div>
        
        <div class="grid md:grid-cols-3 gap-8">
          <% @related_projects.each do |project| %>
            <div class="bg-white rounded-xl shadow-lg hover:shadow-xl transition-shadow overflow-hidden">
              <!-- Project preview logic similar to index page -->
              <div class="aspect-video bg-gradient-to-br from-primary-100 to-secondary-100"></div>
              <div class="p-6">
                <h3 class="text-xl font-bold text-gray-900 mb-2">
                  <%= link_to project.title, project_path(project), class: "hover:text-primary-600 transition-colors" %>
                </h3>
                <p class="text-gray-600 text-sm mb-4"><%= truncate(project.description, length: 100) %></p>
                <%= link_to "View Project", project_path(project), 
                    class: "text-primary-600 hover:text-primary-700 font-medium text-sm" %>
              </div>
            </div>
          <% end %>
        </div>
      </div>
    </div>
  <% end %>
</div>

# app/javascript/controllers/filter_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { url: String }
  static targets = ["form"]

  updateFilter(event) {
    event.preventDefault()
    
    const url = new URL(this.urlValue, window.location.origin)
    const filterParam = event.currentTarget.dataset.filterParam
    const filterValue = event.currentTarget.dataset.filterValue
    
    // Update URL parameters
    if (filterValue) {
      url.searchParams.set(filterParam, filterValue)
    } else {
      url.searchParams.delete(filterParam)
    }
    
    // Update browser history
    history.pushState({}, "", url.pathname + url.search)
    
    // Make turbo stream request
    fetch(url.pathname + url.search, {
      headers: {
        "Accept": "text/vnd.turbo-stream.html",
        "X-Requested-With": "XMLHttpRequest"
      }
    })
    .then(response => response.text())
    .then(html => {
      Turbo.renderStreamMessage(html)
    })
  }
}

# app/javascript/controllers/project_grid_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["card"]

  connect() {
    this.animateCards()
  }

  animateCards() {
    this.cardTargets.forEach((card, index) => {
      card.style.opacity = "0"
      card.style.transform = "translateY(20px)"
      
      setTimeout(() => {
        card.style.transition = "all 0.6s ease-out"
        card.style.opacity = "1"
        card.style.transform = "translateY(0)"
      }, index * 100)
    })
  }
}

# routes.rb
Rails.application.routes.draw do
  root 'home#index'
  
  resources :projects, only: [:index, :show] do
    collection do
      get :filter # For Hotwire filtering
    end
  end
  
  resources :services, only: [:index, :show]
  resources :leads, only: [:create]
  resources :contact, only: [:index, :create]
  
  namespace :admin do
    resources :projects
    resources :clients
    resources :services
    resources :technologies
    resources :testimonials
    resources :leads, only: [:index, :show, :update]
    root 'projects#index'
  end
  
  # API endpoints for lead scoring
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :leads, only: [:create, :show, :update]
    end
  end
end