class UserProfileSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :bio, :location, :website_url, :profile_picture_url,
             :date_of_birth, :created_at, :updated_at, :user_id, :latitude, :longitude,
             :total_created_campaigns, :total_donations, :total_donated_amount,
             :total_raised_amount

  belongs_to :user

  def profile_picture_url
    object.profile_image.attached? ? url_for(object.profile_image) : nil
  end

  def total_created_campaigns
    object.user.campaigns.count
  end

  def total_donations
    object.user.donations.count
  end

  def total_donated_amount
    object.user.donations.sum(:amount)
  end

  def total_raised_amount
    object.user.campaigns.sum(:current_amount)
  end
end
