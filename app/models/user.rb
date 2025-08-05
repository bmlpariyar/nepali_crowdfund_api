class User < ApplicationRecord
  has_many :campaigns, dependent: :destroy
  has_many :donations, dependent: :nullify
  has_one :user_profile, dependent: :destroy
  has_many :update_messages, dependent: :destroy
  has_many :campaign_views, dependent: :destroy
  has_secure_password

  has_many :created_conversations, class_name: "Conversation", foreign_key: "creator_id"

  # As donor
  has_many :donor_conversations, class_name: "Conversation", foreign_key: "donor_id"

  validates :full_name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }

  after_create :create_user_profile_record

  def all_conversations
    Conversation.where("creator_id = ? OR donor_id = ?", id, id)
  end

  private

  def create_user_profile_record
    UserProfile.create(user: self)
  end
end
