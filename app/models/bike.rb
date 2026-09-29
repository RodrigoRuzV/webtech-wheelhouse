class Bike < ApplicationRecord
  belongs_to :customer
  has_many :repairs, dependent: :restrict_with_error

  before_validation :normalize_serial_number

  validates :make, presence: true
  validates :model, presence: true
  validates :serial_number, presence: true, uniqueness: true

  scope :by_make_and_model, -> { order(:make, :model) }

  # How a bike is shown in a select: a person recognises it by make and
  # model, and tells two identical bikes apart by the serial number.
  def display_name
    "#{make} #{model} (#{serial_number})"
  end

  private

  def normalize_serial_number
    self.serial_number = serial_number.strip.upcase if serial_number.present?
  end
end
