class LeadsController < ApplicationController
  before_action :set_lead, only: [:show]
  before_action :check_rate_limit, only: [:create]

  def create
    # Spam prevention: Check honeypot field
    if params[:website_url].present?
      Rails.logger.warn "Potential spam submission detected from IP: #{request.remote_ip}"
      redirect_to root_path, alert: "Your submission could not be processed."
      return
    end

    @lead = Lead.new(lead_params)

    if @lead.save
      # Send email notification asynchronously
      LeadNotificationMailer.new_lead_notification(@lead).deliver_later

      flash[:notice] = "Thank you for your interest! We'll get back to you #{@lead.response_time_target.downcase}."
      redirect_to thank_you_path
    else
      flash.now[:alert] = "Please correct the errors below."
      render :new, status: :unprocessable_entity
    end
  end

  def new
    @lead = Lead.new
  end

  def show
    # Show lead details (for admin or lead owner)
  end

  def thank_you
    # Thank you page after successful lead submission
  end

  private

  def set_lead
    @lead = Lead.find(params[:id])
  end

  def check_rate_limit
    # Simple rate limiting: max 3 submissions per IP per hour
    cache_key = "lead_submission_#{request.remote_ip}"
    submission_count = Rails.cache.read(cache_key) || 0

    if submission_count >= 3
      Rails.logger.warn "Rate limit exceeded for IP: #{request.remote_ip}"
      redirect_to root_path, alert: "Too many submissions. Please try again later."
      return
    end

    # Increment counter
    Rails.cache.write(cache_key, submission_count + 1, expires_in: 1.hour)
  end

  def lead_params
    params.require(:lead).permit(
      :first_name, :last_name, :email, :phone, :company, :website,
      :project_type, :budget, :timeline, :project_description,
      :preferred_contact_method, :source
    )
  end
end