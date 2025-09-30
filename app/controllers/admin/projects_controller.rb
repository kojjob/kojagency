class Admin::ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  def index
    @projects = Project.includes(:technologies, :services)
                      .recent
                      .page(params[:page])
                      .per(20)
  end

  def show
  end

  def new
    @project = Project.new
  end

  def edit
  end

  def create
    @project = Project.new(project_params)

    if @project.save
      redirect_to admin_project_path(@project), notice: 'Project was successfully created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @project.update(project_params)
      redirect_to admin_project_path(@project), notice: 'Project was successfully updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @project.destroy
    redirect_to admin_projects_path, notice: 'Project was successfully deleted.'
  end

  private

  def set_project
    @project = Project.friendly.find(params[:id])
  end

  def project_params
    params.require(:project).permit(
      :title, :description, :client_name, :project_url, :github_url,
      :completion_date, :duration_months, :team_size, :status, :featured,
      :featured_image, :remove_featured_image,
      technology_ids: [], service_ids: [], gallery_images: []
    )
  end

  def require_admin!
    redirect_to root_path, alert: 'Access denied.' unless current_user&.admin?
  end
end
