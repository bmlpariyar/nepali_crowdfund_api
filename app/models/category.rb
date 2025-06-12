class Category < ApplicationRecord
  has_many :campaigns, dependent: :destroy
  validates :name, uniqueness: true, presence: true
  validates :slug, uniqueness: true, presence: true

  before_validation :generate_slug, on: [:create, :update]

  def generate_slug
    self.slug = name.parameterize
  end
end
