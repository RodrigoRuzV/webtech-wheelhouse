class Customer < ApplicationRecord
  has_many :bikes

  before_destroy :ensure_no_bikes

  has_many :repairs, dependent: :restrict_with_error
  has_many :repairs_through_bikes, through: :bikes, source: :repairs

  validates :name, presence: true
  validates :phone, presence: true

  scope :by_name, -> { order(:name) }

  private

  def ensure_no_bikes
    if bikes.any?
      errors.add(:base, "This customer owns at least one bike, so they can't be deleted")
      throw :abort
    end
  end
end
