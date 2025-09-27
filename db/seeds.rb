# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

# Clear existing data in development
if Rails.env.development?
  puts "Cleaning existing data..."
  # First destroy join tables
  BlogPostTag.destroy_all
  BlogRelatedPost.destroy_all
  BlogMediaAttachment.destroy_all
  # Then destroy posts
  BlogPost.destroy_all
  # Then destroy tags
  BlogTag.destroy_all
  # Destroy subcategories first (those with parents)
  BlogCategory.where.not(parent_id: nil).destroy_all
  # Then destroy parent categories
  BlogCategory.destroy_all
  # Finally destroy authors and other independent models
  BlogAuthor.destroy_all
  BlogSubscription.destroy_all
  BlogMedia.destroy_all
end

# Load blog seed data
require_relative 'seeds/blog_seeds'
