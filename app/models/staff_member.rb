class StaffMember < ApplicationRecord
  has_many :intake_repairs, class_name: "Repair", foreign_key: :intake_staff_id, dependent: :restrict_with_error
  has_many :mechanic_repairs, class_name: "Repair", foreign_key: :mechanic_id, dependent: :restrict_with_error
  has_many :returned_repairs, class_name: "Repair", foreign_key: :returned_by_staff_id, dependent: :restrict_with_error

  # The column is still a string holding the same three values the seeds
  # always wrote; the enum adds the predicates, the scopes (e.g.
  # StaffMember.mechanic) and the list of choices the form's select is built
  # from. validate: true turns an unknown role into a validation error
  # instead of an ArgumentError (a blank role is left to the presence check).
  enum :role, {
    mechanic: "mechanic",
    receptionist: "receptionist",
    owner: "owner"
  }, validate: { allow_nil: true }

  validates :name, presence: true
  validates :role, presence: true

  scope :by_role_and_name, -> { order(:role, :name) }
end
