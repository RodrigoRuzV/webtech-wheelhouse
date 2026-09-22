class Repair < ApplicationRecord
  belongs_to :bike
  belongs_to :customer
  belongs_to :intake_staff, class_name: "StaffMember"
  belongs_to :mechanic, class_name: "StaffMember", optional: true
  belongs_to :returned_by_staff, class_name: "StaffMember", optional: true
  has_many :repair_jobs, dependent: :destroy
  has_many :services, through: :repair_jobs

  enum :status, {
    dropped_off: "dropped_off",
    diagnosing: "diagnosing",
    awaiting_approval: "awaiting_approval",
    in_progress: "in_progress",
    declined_pickup_pending: "declined_pickup_pending",
    ready_for_pickup: "ready_for_pickup",
    picked_up: "picked_up"
  }

  validates :status, presence: true

  validate :promised_and_returned_not_before_drop_off
  validate :answer_recorded_for_states_after_quote

  scope :newest_first, -> { order(created_at: :desc) }
  scope :open, -> { where(returned_at: nil) }
  scope :overdue, -> { open.where("promised_on < ?", Date.current) }

  # Mirrors the "Derived, or stored?" decision in docs/domain-model.md:
  # overdue is never a column, it's promised_on in the past on a repair
  # that hasn't come back yet.
  def overdue?
    promised_on.present? && promised_on < Date.current && returned_at.nil?
  end

  def total
    repair_jobs.sum(&:price_charged)
  end

  private

  def promised_and_returned_not_before_drop_off
    return unless created_at

    drop_off_day = created_at.to_date

    if promised_on.present? && promised_on < drop_off_day
      errors.add(:promised_on, "cannot be before the day the bike was dropped off")
    end

    if returned_at.present? && returned_at.to_date < drop_off_day
      errors.add(:returned_at, "cannot be before the day the bike was dropped off")
    end
  end

  def answer_recorded_for_states_after_quote
    if returned_at.present? && !picked_up?
      errors.add(:returned_at, "cannot be set unless the repair has been picked up")
    end

    if (in_progress? || declined_pickup_pending?) && quoted_at.blank?
      errors.add(:quoted_at, "must be recorded once the customer has answered the quote")
    end
  end
end
