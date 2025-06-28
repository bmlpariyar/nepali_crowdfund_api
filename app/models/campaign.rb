class Campaign < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :donations, dependent: :destroy
  has_one_attached :cover_image
  has_many :update_messages, dependent: :destroy
  has_many :campaign_views, dependent: :destroy
  geocoded_by :address

  has_many :chat_messages, dependent: :destroy

  validates :user, presence: true
  validates :category, presence: true
  validates :title, presence: true
  validates :story, presence: true
  validates :funding_goal, presence: true, numericality: { greater_than: 0 }
  validates :current_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :deadline, presence: true
  validates :status, presence: true
  validates :slug, presence: true, uniqueness: true

  before_validation :generate_slug, on: [:create, :update]
  after_validation :geocode, if: ->(obj) { obj.address.present? and obj.address_changed? }

  scope :fully_funded_completed, -> {
          where(status: "funded").where("current_amount >= funding_goal")
        }

  scope :high_potential_ongoing, -> {
          where(status: "active").where("current_amount >= funding_goal * 0.80")
        }

  scope :active, -> { where(status: "active") }

  def generate_slug
    self.slug = title.parameterize
  end

  def unread_chat_messages_for_creator
    chat_messages.where(sender_type: "donor", read: false)
  end

  def unread_chat_messages_for_donors
    chat_messages.where(sender_type: "creator", read: false)
  end

  def chat_participants
    User.joins(:chat_messages)
        .where(chat_messages: { campaign_id: id })
        .distinct
  end
end
