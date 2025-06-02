class Campaign < ApplicationRecord
  belongs_to :user
  belongs_to :category
  has_many :donations, dependent: :destroy
  has_one_attached :cover_image
  has_many :update_messages, dependent: :destroy

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

  def generate_slug
    self.slug = title.parameterize
  end
end
