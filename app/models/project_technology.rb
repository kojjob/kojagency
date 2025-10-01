class ProjectTechnology < ApplicationRecord
  belongs_to :project
  belongs_to :technology

  validates :project_id, uniqueness: { scope: :technology_id }
end
