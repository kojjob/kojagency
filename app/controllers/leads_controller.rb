class LeadsController < ApplicationController
  before_action :set_lead, only: [:show]

  def create
    @lead = Lead.new(lead_params)

    if @lead.save
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

  def lead_params
    params.require(:lead).permit(
      :first_name, :last_name, :email, :phone, :company, :website,
      :project_type, :budget, :timeline, :project_description,
      :preferred_contact_method, :source
    )
  end
end