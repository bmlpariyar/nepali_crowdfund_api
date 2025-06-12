class RecommendationsController < ApplicationController
  before_action :authorized

  def index
    service = RecommendationService.new(@current_user)
    recommended_campaigns = service.generate_recommendations

    render json: recommended_campaigns, each_serializer: CampaignSearchSerializer,
           status: :ok
  end
end
