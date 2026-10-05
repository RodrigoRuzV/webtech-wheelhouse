# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_05_184105) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "bikes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.string "make", null: false
    t.string "model", null: false
    t.string "serial_number", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_bikes_on_customer_id"
    t.index ["serial_number"], name: "index_bikes_on_serial_number", unique: true
  end

  create_table "customers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "phone", null: false
    t.datetime "updated_at", null: false
  end

  create_table "repair_jobs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "price_charged", precision: 8, scale: 2, null: false
    t.bigint "repair_id", null: false
    t.bigint "service_id", null: false
    t.datetime "updated_at", null: false
    t.index ["repair_id"], name: "index_repair_jobs_on_repair_id"
    t.index ["service_id"], name: "index_repair_jobs_on_service_id"
  end

  create_table "repairs", force: :cascade do |t|
    t.bigint "bike_id", null: false
    t.datetime "created_at", null: false
    t.bigint "customer_id", null: false
    t.datetime "finished_at"
    t.bigint "intake_staff_id", null: false
    t.bigint "mechanic_id"
    t.date "promised_on"
    t.datetime "quoted_at"
    t.datetime "returned_at"
    t.bigint "returned_by_staff_id"
    t.string "status", default: "dropped_off", null: false
    t.datetime "updated_at", null: false
    t.index ["bike_id"], name: "index_repairs_on_bike_id"
    t.index ["customer_id"], name: "index_repairs_on_customer_id"
    t.index ["intake_staff_id"], name: "index_repairs_on_intake_staff_id"
    t.index ["mechanic_id"], name: "index_repairs_on_mechanic_id"
    t.index ["returned_by_staff_id"], name: "index_repairs_on_returned_by_staff_id"
  end

  create_table "services", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.decimal "price", precision: 8, scale: 2, null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_services_on_name", unique: true
  end

  create_table "staff_members", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "role", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "bikes", "customers"
  add_foreign_key "repair_jobs", "repairs"
  add_foreign_key "repair_jobs", "services"
  add_foreign_key "repairs", "bikes"
  add_foreign_key "repairs", "customers"
  add_foreign_key "repairs", "staff_members", column: "intake_staff_id"
  add_foreign_key "repairs", "staff_members", column: "mechanic_id"
  add_foreign_key "repairs", "staff_members", column: "returned_by_staff_id"
end
