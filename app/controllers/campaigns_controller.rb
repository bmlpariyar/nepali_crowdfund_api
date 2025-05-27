class CampaignsController < ApplicationController
  skip_before_action :authorized, only: [:index, :show]
  before_action :set_campaign, only: [:show, :update, :destroy]
  before_action :check_ownership, only: [:update, :destroy]

  def index
    @campaigns = Campaign.all.order(created_at: :desc)
    render json: @campaigns, each_serializer: CampaignSerializer, status: :ok
  end

  def show
    render json: CampaignSerializer.new(@campaign).as_json, status: :ok
  end

  def create
    @campaign = @current_user.campaigns.build(campaign_params)
    if @campaign.save
      render json: CampaignSerializer.new(@campaign).as_json, status: :created
    else
      render json: { errors: @campaign.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    if @campaign.update(campaign_params)
      render json: CampaignSerializer.new(@campaign).as_json, status: :ok
    else
      render json: { errors: @campaign.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    if @campaign.destroy
      render json: { message: "Campaign deleted successfully" }, status: :ok
    else
      render json: { errors: @campaign.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def set_campaign
    @campaign = Campaign.find(params[:id])
    unless @campaign
      render json: { message: "Campaign not found" }, status: :not_found
    end
  end

  def campaign_params
    params.require(:campaign).permit(:title, :story, :funding_goal, :deadline, :category_id, :image_url, :video_url)
  end

  def check_ownership
    unless @campaign.user_id == @current_user.id
      render json: { message: "You are not authorized to perform this action" }, status: :unauthorized
    end
  end
end
