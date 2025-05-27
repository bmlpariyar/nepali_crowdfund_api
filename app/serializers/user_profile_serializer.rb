class UserProfileSerializer < ActiveModel::Serializer
  attributes :id, :bio, :location, :website_url, :profile_picture_url, :date_of_birth
  belongs_to :user
end
