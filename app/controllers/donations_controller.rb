class DonationsController < ApplicationController
  before_action :authorized
  before_action :set_campaign

  def create
    unless @campaign.status == "active"
      render json: { error: "This campaign is not currently active and cannot accept donations. Status: #{@campaign.status}" }, status: :forbidden
      return
    end

    if @campaign.deadline.present? && @campaign.deadline < Time.current
      render json: { error: "This campaign has passed its deadline and can no longer accept donations." }, status: :forbidden
      return
    end
    @donation = @campaign.donations.build(donation_params)
    @donation.user = @current_user
    @donation.status = "Completed"

    ActiveRecord::Base.transaction do
      if @donation.save
        new_current_amount = @campaign.current_amount + @donation.amount
        @campaign.update!(current_amount: new_current_amount)

        if @campaign.status == "active" && new_current_amount >= @campaign.funding_goal
          @campaign.update!(status: "funded")
        end
        render json: { message: "Donation created successfully", donation: DonationSerializer.new(@donation).as_json }, status: :created
      else
        render json: { errors: @donation.errors.full_messages }, status: :unprocessable_entity
        raise ActiveRecord::Rollback
      end
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Campaign not found" }, status: :not_found
  rescue ActiveRecord::RecordInvalid => e # Catch validation errors from update!
    render json: { error: "Could not process donation: #{e.message}" }, status: :unprocessable_entity
  rescue => e
    render json: { error: "Could not process donation: #{e.message}" }, status: :internal_server_error
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:campaign_id])
    unless @campaign
      render json: { message: "Campaign not found" }, status: :not_found
    end
  end

  def donation_params
    params.require(:donation).permit(:amount, :is_anonymous)
  end
end
