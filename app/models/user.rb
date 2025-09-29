class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Associations
  has_many :blog_posts, as: :author, dependent: :destroy
  has_many :blog_comments, class_name: 'BlogComment', dependent: :destroy

  # Validations
  validates :name, presence: true

  # Enums
  enum :role, { user: 0, admin: 1, super_admin: 2 }

  # Callbacks
  before_save :normalize_email

  # Scopes
  scope :admins, -> { where(role: [:admin, :super_admin]) }
  scope :super_admins, -> { where(role: :super_admin) }

  # Check if user is admin (for backwards compatibility with existing admin controllers)
  def admin?
    role == 'admin' || role == 'super_admin'
  end

  # Check if user is super admin
  def super_admin?
    role == 'super_admin'
  end

  # Check if user can perform CRUD on all models
  def can_manage_all?
    super_admin?
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end