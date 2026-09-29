class RepairJob < ApplicationRecord
  belongs_to :repair
  belongs_to :service

  # The messages name the line (by its service), so an error on a repair's
  # form says which line is wrong, not only that "the repair" is.
  validates :price_charged,
    presence: { message: ->(job, _data) { "on the #{job.line_name} line can't be blank" } },
    numericality: { greater_than: 0, allow_nil: true,
                    message: ->(job, _data) { "on the #{job.line_name} line must be a number greater than 0" } }

  def line_name
    service&.name || "new"
  end

  scope :newest_first, -> { order(created_at: :desc) }
end
