class CreateRepairJobs < ActiveRecord::Migration[8.1]
  def change
    create_table :repair_jobs do |t|
      t.references :repair, null: false
      t.references :service, null: false
      t.decimal :price_charged, precision: 8, scale: 2, null: false

      t.timestamps
    end
  end
end
