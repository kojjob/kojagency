class BlogSubscription < ApplicationRecord
  # Validations
  validates :email, presence: true,
                   uniqueness: { case_sensitive: false },
                   format: { with: URI::MailTo::EMAIL_REGEXP }

  # Normalize email
  before_validation :normalize_email

  # Scopes
  scope :active, -> { where(active: true) }
  scope :confirmed, -> { where.not(confirmed_at: nil) }

  def confirmed?
    confirmed_at.present?
  end

  def activate!
    update!(active: true)
  end

  def deactivate!
    update!(active: false)
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end
