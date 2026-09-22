class StaffMember < ApplicationRecord
  has_many :intake_repairs, class_name: "Repair", foreign_key: :intake_staff_id, dependent: :restrict_with_error
  has_many :mechanic_repairs, class_name: "Repair", foreign_key: :mechanic_id, dependent: :restrict_with_error
  has_many :returned_repairs, class_name: "Repair", foreign_key: :returned_by_staff_id, dependent: :restrict_with_error

  validates :name, presence: true
  validates :role, presence: true

  scope :by_role_and_name, -> { order(:role, :name) }
end
