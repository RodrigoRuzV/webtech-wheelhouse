class Service < ApplicationRecord
  has_many :repair_jobs
  has_many :repairs, through: :repair_jobs

  before_validation :normalize_name
  before_destroy :ensure_not_charged

  validates :name, presence: true, uniqueness: true
  validates :price, presence: true, numericality: { greater_than: 0 }

  scope :by_name, -> { order(:name) }

  private

  def normalize_name
    self.name = name.strip if name.present?
  end

  def ensure_not_charged
    if repair_jobs.any?
      errors.add(:base, "cannot be deleted because it has been charged on at least one repair")
      throw :abort
    end
  end
end
