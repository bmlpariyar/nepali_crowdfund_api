class CampaignSerializer < ActiveModel::Serializer
  attributes :id, :user, :category, :title, :story, :funding_goal, :current_amount, :deadline, :status
end
