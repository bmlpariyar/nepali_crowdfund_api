class CampaignView < ApplicationRecord
  belongs_to :user
  belongs_to :campaign
  validates :user_id, uniqueness: { scope: :campaign_id, message: "has already viewed this campaign recently" }
end
