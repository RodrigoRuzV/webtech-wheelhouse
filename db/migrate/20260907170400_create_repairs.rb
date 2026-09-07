class CreateRepairs < ActiveRecord::Migration[8.1]
  def change
    create_table :repairs do |t|
      t.references :bike, null: false
      t.references :customer, null: false
      t.references :intake_staff, null: false
      t.references :mechanic, null: true
      t.date :promised_on
      t.string :status, null: false, default: "dropped_off"
      t.datetime :quoted_at
      t.datetime :finished_at
      t.datetime :returned_at
      t.references :returned_by_staff, null: true

      t.timestamps
    end
  end
end
