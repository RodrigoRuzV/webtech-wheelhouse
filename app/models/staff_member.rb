class StaffMember < ApplicationRecord
  # Lab 11: a member of the staff with an account can't be destroyed. The
  # refusal ("Cannot delete record because a dependent user exists") reaches
  # the page as the alert of every refused destroy. Declared first, so it is
  # the reason given even when the member also has repairs.
  has_one :user, dependent: :restrict_with_error

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
