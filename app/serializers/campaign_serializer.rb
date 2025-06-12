class CampaignSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :user, :category, :title, :story, :funding_goal, :current_amount, :deadline, :status, :cover_image_url, :video_url, :latitude, :longitude, :total_donations, :created_at, :updated_at, :user_profile

  belongs_to :user, serializer: UserSerializer

  def cover_image_url
    object.cover_image.attached? ? url_for(object.cover_image) : nil
  end

  def user_profile
    UserProfileSerializer.new(object.user.user_profile, scope: scope) if object.user&.user_profile
  end

  def total_donations
    object.donations.count
  end
end
