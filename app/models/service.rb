class Service < ApplicationRecord
  extend FriendlyId
  friendly_id :name, use: [:slugged, :history]

  # Associations
  has_many :project_services, dependent: :destroy
  has_many :projects, through: :project_services

  # Validations
  validates :name, presence: true, length: { maximum: 100 }
  validates :description, presence: true, length: { minimum: 50, maximum: 2000 }
  validates :slug, uniqueness: { case_sensitive: false }

  # Instance methods
  def features_list
    return [] if features.blank?

    features.split("\n").map(&:strip).reject(&:empty?)
  end
end
