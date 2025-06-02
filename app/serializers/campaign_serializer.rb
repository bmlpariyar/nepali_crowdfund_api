class CampaignSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :user, :category, :title, :story, :funding_goal, :current_amount, :deadline, :status, :cover_image_url, :video_url, :total_donations, :created_at, :updated_at

  def cover_image_url
    object.cover_image.attached? ? url_for(object.cover_image) : "no url"
  end

  def total_donations
    object.donations.count
  end
end
