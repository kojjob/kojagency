require 'rails_helper'

RSpec.describe "Admin::Projects", type: :request do
  let(:admin_user) { create(:user, :admin) }
  let(:valid_attributes) do
    {
      title: 'Enterprise Analytics Platform',
      description: 'A comprehensive analytics platform built for enterprise clients with real-time data processing and custom dashboards.',
      client_name: 'Tech Corp Inc',
      project_url: 'https://techcorp.com',
      github_url: 'https://github.com/techcorp/analytics',
      completion_date: 6.months.ago,
      duration_months: 12,
      team_size: 8,
      status: 'published',
      featured: true
    }
  end

  let(:invalid_attributes) do
    {
      title: '',
      description: 'Too short',
      client_name: '',
      status: 'published'
    }
  end

  before do
    sign_in admin_user
  end

  describe "GET /admin/projects" do
    it "returns success" do
      get admin_projects_path
      expect(response).to have_http_status(:success)
    end

    it "displays all projects" do
      project1 = create(:project, title: 'Project One')
      project2 = create(:project, title: 'Project Two')

      get admin_projects_path

      expect(response.body).to include('Project One')
      expect(response.body).to include('Project Two')
    end
  end

  describe "GET /admin/projects/:id" do
    let(:project) { create(:project) }

    it "returns success" do
      get admin_project_path(project)
      expect(response).to have_http_status(:success)
    end

    it "displays project details" do
      get admin_project_path(project)

      expect(response.body).to include(project.title)
      expect(response.body).to include(project.client_name)
    end
  end

  describe "GET /admin/projects/new" do
    it "returns success" do
      get new_admin_project_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /admin/projects" do
    context "with valid parameters" do
      it "creates a new Project" do
        expect {
          post admin_projects_path, params: { project: valid_attributes }
        }.to change(Project, :count).by(1)
      end

      it "redirects to the created project" do
        post admin_projects_path, params: { project: valid_attributes }
        expect(response).to redirect_to(admin_project_path(Project.last))
      end

      it "sets success notice" do
        post admin_projects_path, params: { project: valid_attributes }
        follow_redirect!
        expect(response.body).to include('Project was successfully created')
      end
    end

    context "with invalid parameters" do
      it "does not create a new Project" do
        expect {
          post admin_projects_path, params: { project: invalid_attributes }
        }.to change(Project, :count).by(0)
      end

      it "renders new template with unprocessable entity status" do
        post admin_projects_path, params: { project: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /admin/projects/:id/edit" do
    let(:project) { create(:project) }

    it "returns success" do
      get edit_admin_project_path(project)
      expect(response).to have_http_status(:success)
    end
  end

  describe "PATCH /admin/projects/:id" do
    let(:project) { create(:project) }
    let(:new_attributes) do
      {
        title: 'Updated Title',
        description: 'This is an updated description that is long enough to pass validation requirements for our project model.'
      }
    end

    context "with valid parameters" do
      it "updates the requested project" do
        patch admin_project_path(project), params: { project: new_attributes }
        project.reload
        expect(project.title).to eq('Updated Title')
      end

      it "redirects to the project" do
        patch admin_project_path(project), params: { project: new_attributes }
        expect(response).to redirect_to(admin_project_path(project))
      end
    end

    context "with invalid parameters" do
      it "renders edit template with unprocessable entity status" do
        patch admin_project_path(project), params: { project: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "DELETE /admin/projects/:id" do
    let!(:project) { create(:project) }

    it "destroys the requested project" do
      expect {
        delete admin_project_path(project)
      }.to change(Project, :count).by(-1)
    end

    it "redirects to the projects list" do
      delete admin_project_path(project)
      expect(response).to redirect_to(admin_projects_path)
    end
  end
end