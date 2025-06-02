class UpdateMessage < ApplicationRecord
  belongs_to :user
  belongs_to :campaign

  has_one_attached :media_image
  validates :message, presence: true
end
