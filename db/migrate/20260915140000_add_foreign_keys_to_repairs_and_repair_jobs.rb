class AddForeignKeysToRepairsAndRepairJobs < ActiveRecord::Migration[8.1]
  def change
    add_foreign_key :repairs, :bikes
    add_foreign_key :repairs, :customers
    add_foreign_key :repairs, :staff_members, column: :intake_staff_id
    add_foreign_key :repairs, :staff_members, column: :mechanic_id
    add_foreign_key :repairs, :staff_members, column: :returned_by_staff_id
    add_foreign_key :repair_jobs, :repairs
    add_foreign_key :repair_jobs, :services
  end
end
