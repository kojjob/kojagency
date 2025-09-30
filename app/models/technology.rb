class Technology < ApplicationRecord
  # Associations
  has_many :project_technologies, dependent: :destroy
  has_many :projects, through: :project_technologies

  # Validations
  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 100 }
  validates :category, presence: true
  validates :description, length: { maximum: 1000 }, allow_blank: true

  # Scopes
  scope :by_category, ->(category) { where(category: category) }
  scope :ordered_by_name, -> { order(:name) }
end
