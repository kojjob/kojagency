class ProjectService < ApplicationRecord
  belongs_to :project
  belongs_to :service

  validates :project_id, uniqueness: { scope: :service_id }
end
