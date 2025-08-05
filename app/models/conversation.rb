class Conversation < ApplicationRecord
  belongs_to :campaign
  belongs_to :creator, class_name: "User"
  belongs_to :donor, class_name: "User"
  has_many :chat_messages, dependent: :destroy

  # Validation to ensure creator and donor are different
  validate :creator_and_donor_must_be_different

  # Validation to ensure creator is actually the campaign creator
  validate :creator_must_own_campaign

  def other_participant(user)
    user.id == creator_id ? donor : creator
  end

  def participants
    [creator, donor]
  end

  private

  def creator_and_donor_must_be_different
    errors.add(:donor, "cannot be the same as creator") if creator_id == donor_id
  end

  def creator_must_own_campaign
    errors.add(:creator, "must be the campaign owner") if campaign && creator_id != campaign.user_id
  end
end
