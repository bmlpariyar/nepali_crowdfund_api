class Donation < ApplicationRecord
  belongs_to :user
  belongs_to :campaign

  validates :user, presence: true
  validates :campaign, presence: true
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true

  after_save :update_campaign_amount, if: -> { completed? && saved_change_to_status? }

  def update_campaign_amount
    campaign.increment!(:current_amount, amount)
  end

  def completed?
    status == "completed"
  end
end
