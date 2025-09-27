class BlogComment < ApplicationRecord
  belongs_to :blog_post, counter_cache: true
  belongs_to :parent, class_name: 'BlogComment', optional: true
  has_many :replies, class_name: 'BlogComment', foreign_key: 'parent_id', dependent: :destroy

  # Validations
  validates :author_name, presence: true, length: { maximum: 100 }
  validates :author_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :content, presence: true, length: { minimum: 3, maximum: 1000 }
  validates :author_website, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]), allow_blank: true }

  # Enums
  enum :status, { pending: 0, approved: 1, spam: 2, rejected: 3 }, default: :pending

  # Scopes
  scope :approved, -> { where(status: :approved) }
  scope :pending, -> { where(status: :pending) }
  scope :recent, -> { order(created_at: :desc) }
  scope :root_comments, -> { where(parent_id: nil) }

  # Methods
  def gravatar_url(size = 80)
    hash = Digest::MD5.hexdigest(author_email.downcase.strip)
    "https://www.gravatar.com/avatar/#{hash}?s=#{size}&d=mp"
  end

  def approved?
    status == 'approved'
  end

  def has_replies?
    replies.any?
  end

  def depth
    parent ? parent.depth + 1 : 0
  end

  def max_depth_reached?
    depth >= 3 # Allow up to 3 levels of nesting
  end

  def approve!
    update!(status: :approved)
  end
end
