class DonationSerializer < ActiveModel::Serializer
  attributes :id, :amount, :status, :is_anonymous, :user_id, :campaign_id, :created_at, :updated_at, :campaign_current_amount, :support_message
  belongs_to :user

  def campaign_current_amount
    object.campaign&.current_amount
  end
end
