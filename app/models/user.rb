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
  enum :role, { user: 0, admin: 1 }

  # Callbacks
  before_save :normalize_email

  # Scopes
  scope :admins, -> { where(role: :admin) }

  # Check if user is admin (for backwards compatibility with existing admin controllers)
  def admin?
    role == 'admin'
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end