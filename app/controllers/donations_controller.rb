class DonationsController < ApplicationController
  before_action :authorized, only: [:create]
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

    unless params[:donation][:amount].present? && (params[:donation][:amount].to_f > 0 && params[:donation][:amount].to_f <= 100000)
      render json: { error: "Donation amount cannot exceed Rs 100,000 at a time" }, status: :unprocessable_entity
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

  def get_support_messages
    @campaign = Campaign.find(params[:campaign_id])

    @support_messages = @campaign.donations
      .where.not(support_message: [nil, ""])
      .includes(:user)
      .order(created_at: :desc)
      .map do |donation|
      {
        id: donation.id,
        username: donation.is_anonymous ? "Anonymous" : donation.user&.full_name || donation.user&.email,
        amount: donation.amount,
        message: donation.support_message,
        user_avater: donation.user&.user_profile&.profile_image&.attached? ? url_for(donation.user&.user_profile.profile_image) : "default_avatar_url",
        created_at: donation.created_at,
      }
    end

    render json: { support_messages: @support_messages }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Campaign not found" }, status: :not_found
  rescue => e
    render json: { error: "Could not retrieve support messages: #{e.message}" }, status: :internal_server_error
  end

  def get_all_donations
    @donations = @campaign.donations.order(created_at: :desc)
    render json: @donations, each_serializer: DonationSerializer, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Campaign not found" }, status: :not_found
  rescue => e
    render json: { error: "Could not retrieve donations: #{e.message}" }, status: :internal_server_error
  end

  def get_top_donations
    @top_donations = @campaign.donations
      .where.not(amount: nil)
      .order(amount: :desc)
      .limit(10)
    render json: @top_donations, each_serializer: DonationSerializer, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Campaign not found" }, status: :not_found
  rescue => e
    render json: { error: "Could not retrieve top donations: #{e.message}" }, status: :internal_server_error
  end

  def donation_highlight
    if @campaign.donations.empty?
      render json: { error: "No donations found for this campaign" }, status: :not_found
      return
    end
    top_donation = @campaign.donations.where.not(amount: nil).order(amount: :desc).first
    first_donation = @campaign.donations.order(created_at: :asc).first
    recent_donation = @campaign.donations.order(created_at: :desc).first

    render json: {

      top_donation: top_donation ? DonationSerializer.new(top_donation).as_json : nil,
      first_donation: first_donation ? DonationSerializer.new(first_donation).as_json : nil,
      recent_donation: recent_donation ? DonationSerializer.new(recent_donation).as_json : nil,

    }, status: :ok
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Campaign not found" }, status: :not_found
  rescue => e
    render json: { error: "Could not retrieve donation highlights: #{e.message}" }, status: :internal_server_error
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:campaign_id])
    unless @campaign
      render json: { message: "Campaign not found" }, status: :not_found
    end
  end

  def donation_params
    params.require(:donation).permit(:amount, :is_anonymous, :support_message)
  end
end
