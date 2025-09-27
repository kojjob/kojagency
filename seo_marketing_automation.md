# app/controllers/application_controller.rb - SEO & Analytics Setup
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  before_action :set_seo_meta
  before_action :track_visitor
  
  private
  
  def set_seo_meta
    @seo_title = "Digital Agency | Web, Mobile & Data Analytics Solutions"
    @seo_description = "We build scalable web applications, mobile apps, and data analytics platforms using Test-Driven Development and Domain-Driven Design."
    @seo_keywords = "web development, mobile apps, data analytics, ruby on rails, react, swift"
    @canonical_url = request.original_url
  end
  
  def track_visitor
    return if Rails.env.test?
    
    visitor_id = cookies.permanent.signed[:visitor_id] ||