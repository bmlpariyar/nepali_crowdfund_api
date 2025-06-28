class ChatMessage < ApplicationRecord
  belongs_to :campaign
  belongs_to :user

  validates :message, presence: true, length: { maximum: 1000 }
  validates :sender_type, inclusion: { in: %w[creator donor] }

  scope :for_campaign, ->(campaign) { where(campaign: campaign) }
  scope :unread, -> { where(read: false) }
  scope :recent, -> { order(created_at: :desc) }
  scope :chronological, -> { order(created_at: :asc) }

  # after_create :broadcast_message

  def mark_as_read!
    update!(read: true, read_at: Time.current)
  end

  def sender_name
    user.full_name || user.email
  end

  def is_from_creator?
    sender_type == "creator"
  end

  def is_from_donor?
    sender_type == "donor"
  end

  private

  # def broadcast_message
  #   # Optional: Add ActionCable broadcasting for real-time updates
  #   # ActionCable.server.broadcast("campaign_chat_#{campaign_id}", {
  #   #   message: self.as_json(include: :user),
  #   #   type: 'new_message'
  #   # })
  # end
end
