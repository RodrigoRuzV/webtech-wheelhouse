class StaffMember < ApplicationRecord
  has_many :intake_repairs, class_name: "Repair", foreign_key: :intake_staff_id
  has_many :mechanic_repairs, class_name: "Repair", foreign_key: :mechanic_id
  has_many :returned_repairs, class_name: "Repair", foreign_key: :returned_by_staff_id
end
