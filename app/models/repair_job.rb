class RepairJob < ApplicationRecord
  belongs_to :repair
  belongs_to :service

  validates :price_charged, presence: true, numericality: { greater_than: 0 }

  scope :newest_first, -> { order(created_at: :desc) }
end
