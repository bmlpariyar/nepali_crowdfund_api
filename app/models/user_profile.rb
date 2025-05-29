# app/models/user_profile.rb
class UserProfile < ApplicationRecord
  belongs_to :user
  validates :user_id, presence: true, uniqueness: true

  # Add this line for Active Storage
  has_one_attached :profile_image # You can name it :avatar, :picture, etc.

  # Optional: Add validations for the attachment
  # validates :profile_image, content_type: ["image/png", "image/jpg", "image/jpeg"],
  #                           size: { less_than: 5.megabytes, message: "is too large (max 5MB)" },
  #                           allow_blank: true
end
