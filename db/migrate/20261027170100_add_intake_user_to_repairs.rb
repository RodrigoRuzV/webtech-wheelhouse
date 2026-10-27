# Lab 11: a repair records the account that took it in, read from the
# session. NULL for the repairs that existed before accounts.
#
# intake_staff_id (Lab 5) stops being chosen in the form: it can be NULL from
# now on, and is filled from the account's member of the staff when it has
# one (Repair#take_intake_staff_from_user). See docs/decisions.md.
class AddIntakeUserToRepairs < ActiveRecord::Migration[8.1]
  def change
    add_reference :repairs, :intake_user, null: true, foreign_key: { to_table: :users }
    change_column_null :repairs, :intake_staff_id, true
  end
end
