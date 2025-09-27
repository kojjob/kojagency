class EnhanceBlogAuthors < ActiveRecord::Migration[8.1]
  def change
    # Avatar handled by Active Storage (configured in model)
    add_column :blog_authors, :title, :string
    add_column :blog_authors, :company, :string
    add_column :blog_authors, :location, :string
    add_column :blog_authors, :expertise, :text, array: true, default: []
    add_column :blog_authors, :follower_count, :integer, default: 0
    add_column :blog_authors, :verified, :boolean, default: false

    # Social media already exists as JSONB in the existing schema
    # Just documenting the expected structure:
    # {
    #   "twitter": "@handle",
    #   "linkedin": "profile-url",
    #   "github": "username",
    #   "instagram": "@handle",
    #   "website": "https://example.com"
    # }
  end
end
