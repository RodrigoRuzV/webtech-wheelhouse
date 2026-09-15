class Repair < ApplicationRecord
  belongs_to :bike
  belongs_to :customer
  belongs_to :intake_staff, class_name: "StaffMember"
  belongs_to :mechanic, class_name: "StaffMember", optional: true
  belongs_to :returned_by_staff, class_name: "StaffMember", optional: true
  has_many :repair_jobs
end
