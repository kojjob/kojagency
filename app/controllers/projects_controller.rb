class ProjectsController < ApplicationController
  def index
    @projects = Project.published
                       .includes(:technologies, :services, featured_image_attachment: :blob)
                       .recent
                       .page(params[:page])
                       .per(12)

    # Get all unique services for filtering
    @services = Service.joins(:projects)
                       .where(projects: { status: :published })
                       .distinct
                       .order(:name)

    # Filter by service if param present
    if params[:service_id].present?
      @projects = @projects.joins(:services)
                           .where(services: { id: params[:service_id] })
    end
  end

  def show
    @project = Project.published
                      .includes(:technologies, :services,
                               featured_image_attachment: :blob,
                               gallery_images_attachments: :blob)
                      .friendly
                      .find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to projects_path, alert: 'Project not found.'
  end
end