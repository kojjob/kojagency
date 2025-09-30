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

# Create Super Admin User
puts "Creating super admin user..."
super_admin = User.find_or_initialize_by(email: 'imlikeu.io@gmail.com')

if super_admin.new_record?
  super_admin.name = 'Super Admin'
  super_admin.password = ENV['SUPER_ADMIN_PASSWORD'] || 'SuperAdmin123!'
  super_admin.password_confirmation = super_admin.password
  super_admin.save!
  puts "Super admin user created with email: imlikeu.io@gmail.com"
else
  puts "Super admin user already exists"
end

# Ensure user has super_admin role
super_admin.update!(role: :super_admin)
puts "Super admin role assigned to #{super_admin.email}"

# Load blog seed data
require_relative 'seeds/blog_seeds'
