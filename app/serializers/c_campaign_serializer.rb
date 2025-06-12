# app/serializers/c_campaign_serializer.rb
class CCampaignSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  def initialize(campaigns, context = nil)
    @campaigns = Array(campaigns)
    @context = context
  end

  def as_json_with_image_url
    @campaigns.map do |campaign|
      {
        id: campaign.id,
        title: campaign.title,
        story: campaign.story.truncate(100),
        goal_amount: campaign.funding_goal,
        raised_amount: campaign.current_amount,
        category: campaign.category.name,
        user: {
          id: campaign.user.id,
          name: campaign.user.full_name,
        },
        image_url: campaign.cover_image.attached? ? url_for(campaign.cover_image) : nil,
        location: {
          latitude: campaign.latitude,
          longitude: campaign.longitude,
        },
      }
    end
  end
end
