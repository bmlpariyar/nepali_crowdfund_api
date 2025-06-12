class CampaignsController < ApplicationController
  skip_before_action :authorized, only: [:index, :show, :search, :featured_campaigns]
  before_action :set_campaign, only: [:show, :update, :destroy]
  before_action :check_ownership, only: [:update, :destroy]

  def index
    @campaigns = Campaign.order(created_at: :desc).page(params[:page]).per(params[:per_page] || 9)

    render json: {
      campaigns: ActiveModelSerializers::SerializableResource.new(@campaigns, each_serializer: CampaignSerializer),
      pagination: {
        current_page: @campaigns.current_page,
        total_pages: @campaigns.total_pages,
        total_count: @campaigns.total_count,
        per_page: @campaigns.limit_value,
      },
    }, status: :ok
  end

  def show
    @campaign = Campaign.includes(user: :user_profile).find(params[:id])
    render json: @campaign, serializer: CampaignSerializer
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

  def search
    @campaigns = Campaign.includes(:category, :user)

    # Search by name/title and description/story
    if params[:name].present?
      search_term = "%#{params[:name].downcase}%"
      @campaigns = @campaigns.where(
        "LOWER(title) LIKE ? OR LOWER(story) LIKE ?",
        search_term, search_term
      )
    end

    # Filter by status
    if params[:status].present?
      case params[:status].downcase
      when "active"
        @campaigns = @campaigns.where("deadline > ? AND funding_goal > current_amount", Time.current)
      when "funded"
        @campaigns = @campaigns.where("current_amount >= funding_goal")
      when "ended"
        @campaigns = @campaigns.where("deadline <= ?", Time.current)
      end
    end

    # Filter by category
    if params[:category].present?
      @campaigns = @campaigns.where(category_id: params[:category])
    end

    # Filter by goal range
    if params[:min_goal].present?
      @campaigns = @campaigns.where("funding_goal >= ?", params[:min_goal].to_i)
    end

    if params[:max_goal].present?
      @campaigns = @campaigns.where("funding_goal <= ?", params[:max_goal].to_i)
    end

    # Sort results
    case params[:sort_by]
    when "popular"
      @campaigns = @campaigns.left_joins(:donations)
        .group("campaigns.id")
        .order("COUNT(donations.id) DESC")
    when "funded"
      @campaigns = @campaigns.order("(CAST(current_amount AS FLOAT) / CAST(funding_goal AS FLOAT)) DESC")
    when "ending"
      @campaigns = @campaigns.where("deadline > ?", Time.current)
        .order("deadline ASC")
    else # 'recent' or default
      @campaigns = @campaigns.order(created_at: :desc)
    end

    # Add pagination
    page = params[:page] || 1
    per_page = params[:per_page] || 20
    @campaigns = @campaigns.page(page).per(per_page)

    render json: {
      campaigns: ActiveModelSerializers::SerializableResource.new(
        @campaigns,
        each_serializer: CampaignSearchSerializer,
      ),
      pagination: {
        current_page: @campaigns.current_page,
        total_pages: @campaigns.total_pages,
        total_count: @campaigns.total_count,
        per_page: per_page.to_i,
      },
    }, status: :ok
  end

  def featured_campaigns
    completed = Campaign.fully_funded_completed
    ongoing = Campaign.high_potential_ongoing

    donor_counts = Donation.where(campaign_id: ongoing.pluck(:id))
      .group(:campaign_id)
      .count

    qualified_ongoing_ids = donor_counts.select { |_, count| count >= 10 }.keys

    campaigns = Campaign.where(id: completed.pluck(:id) + qualified_ongoing_ids)
                        .order(updated_at: :asc)
                        .limit(4)

    if campaigns.any?
      render json: campaigns, each_serializer: CampaignSearchSerializer
    else
      render json: { message: "No featured success stories found." }, status: :ok
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
    params.require(:campaign).permit(
      :title,
      :story,
      :funding_goal,
      :deadline,
      :category_id,
      :cover_image,
      :video_url,
      :address,
      :latitude,
      :longitude,
    )
  end

  def check_ownership
    unless @campaign.user_id == @current_user.id
      render json: { message: "You are not authorized to perform this action" }, status: :unauthorized
    end
  end
end
