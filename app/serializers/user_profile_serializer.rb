class UserProfileSerializer < ActiveModel::Serializer
  include Rails.application.routes.url_helpers

  attributes :id, :bio, :location, :website_url, :profile_picture_url,
             :date_of_birth, :created_at, :updated_at, :user_id, :latitude, :longitude

  belongs_to :user

  def profile_picture_url
    object.profile_image.attached? ? url_for(object.profile_image) : nil
  end
end
