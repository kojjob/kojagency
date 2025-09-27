class BlogMedia < ApplicationRecord
  self.table_name = 'blog_media'

  # Associations
  has_many :blog_media_attachments, dependent: :destroy
  has_many :posts, through: :blog_media_attachments, source: :blog_post
  has_one_attached :file

  # Validations
  validates :media_type, presence: true, inclusion: { in: %w[image video audio document] }

  # Scopes
  scope :images, -> { where(media_type: 'image') }
  scope :videos, -> { where(media_type: 'video') }
  scope :audio, -> { where(media_type: 'audio') }
  scope :documents, -> { where(media_type: 'document') }

  # Callbacks
  before_save :set_file_attributes

  # Instance Methods
  def image?
    media_type == 'image'
  end

  def video?
    media_type == 'video'
  end

  def audio?
    media_type == 'audio'
  end

  def document?
    media_type == 'document'
  end

  private

  def set_file_attributes
    return unless file.attached?

    self.content_type = file.blob.content_type
    self.file_size = file.blob.byte_size

    if image? && file.blob.analyzed?
      self.metadata = {
        width: file.blob.metadata[:width],
        height: file.blob.metadata[:height]
      }
    end
  end
end