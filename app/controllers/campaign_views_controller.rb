class CampaignViewsController < ApplicationController
  before_action :authorized

  def create
    campaign = Campaign.find(params[:campaign_id])
    begin
      view = campaign.campaign_views.find_or_create_by!(user: @current_user)
      if view.persisted?
        head :ok
      end
    rescue ActiveRecord::RecordNotUnique
      head :ok
    rescue => e
      render json: { errors: [e.message] }, status: :unprocessable_entity
    end
  end
end
