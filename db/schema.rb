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

ActiveRecord::Schema[7.1].define(version: 2026_08_29_160500) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "applied_benefits", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.float "amount", null: false
    t.bigint "users_benefit_id"
    t.bigint "payroll_id", null: false
    t.bigint "benefit_id", null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["benefit_id"], name: "index_applied_benefits_on_benefit_id"
    t.index ["company_id"], name: "index_applied_benefits_on_company_id"
    t.index ["payroll_id"], name: "index_applied_benefits_on_payroll_id"
    t.index ["users_benefit_id"], name: "index_applied_benefits_on_users_benefit_id"
  end

  create_table "applied_leaves", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.date "applied_from", null: false
    t.date "applied_till", null: false
    t.string "state", null: false
    t.integer "leave_duration_type", null: false
    t.boolean "archived", default: false
    t.bigint "user_leave_id"
    t.bigint "company_id", null: false
    t.bigint "user_id", null: false
    t.bigint "leave_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "user_id", "user_leave_id"], name: "index_applied_leaves_on_company_id_and_user_id_and_user_leave_id"
    t.index ["company_id"], name: "index_applied_leaves_on_company_id"
    t.index ["leave_id"], name: "index_applied_leaves_on_leave_id"
    t.index ["user_id"], name: "index_applied_leaves_on_user_id"
    t.index ["user_leave_id"], name: "index_applied_leaves_on_user_leave_id"
  end

  create_table "benefits", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.float "default_amount", null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sequence_num", null: false
    t.index ["company_id", "sequence_num"], name: "index_benefits_on_company_id_and_sequence_num", unique: true
    t.index ["company_id"], name: "index_benefits_on_company_id"
  end

  create_table "companies", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "subdomain", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subdomain"], name: "index_companies_on_subdomain", unique: true
  end

  create_table "delayed_jobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at", precision: nil
    t.datetime "locked_at", precision: nil
    t.datetime "failed_at", precision: nil
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "departments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.bigint "company_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_departments_on_company_id"
  end

  create_table "designations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.bigint "company_id"
    t.bigint "department_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_designations_on_company_id"
  end

  create_table "events", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "starts_at", precision: nil
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "company_id"
    t.index ["company_id"], name: "index_events_on_company_id"
  end

  create_table "leaves", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.float "default_count", null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "name"], name: "index_leaves_on_company_id_and_name", unique: true
    t.index ["company_id"], name: "index_leaves_on_company_id"
  end

  create_table "notifications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "recipient_id"
    t.string "body"
    t.datetime "time", precision: nil
    t.bigint "company_id"
    t.boolean "status", default: false
    t.index ["company_id"], name: "index_notifications_on_company_id"
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
  end

  create_table "payrolls", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.float "gross_salary", null: false
    t.float "salary_after_tax", null: false
    t.float "base_salary", null: false
    t.bigint "user_id", null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sequence_num", null: false
    t.index ["company_id", "sequence_num"], name: "index_payrolls_on_company_id_and_sequence_num", unique: true
    t.index ["company_id", "user_id"], name: "index_payrolls_on_company_id_and_user_id"
    t.index ["company_id"], name: "index_payrolls_on_company_id"
    t.index ["user_id"], name: "index_payrolls_on_user_id"
  end

  create_table "settings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "tax_rate"
    t.bigint "company_id"
    t.datetime "leave_resets_at", precision: nil
    t.index ["company_id"], name: "index_settings_on_company_id"
  end

  create_table "user_leaves", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.float "total_count", null: false
    t.float "remaining_count", null: false
    t.bigint "leave_id"
    t.bigint "user_id", null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_user_leaves_on_company_id"
    t.index ["leave_id"], name: "index_user_leaves_on_leave_id"
    t.index ["user_id", "leave_id"], name: "index_user_leaves_on_user_id_and_leave_id", unique: true
    t.index ["user_id"], name: "index_user_leaves_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.string "confirmation_token"
    t.datetime "confirmed_at", precision: nil
    t.datetime "confirmation_sent_at", precision: nil
    t.string "unconfirmed_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id"
    t.bigint "department_id"
    t.string "first_name"
    t.string "last_name"
    t.date "date_of_birth"
    t.float "base_salary"
    t.integer "role_id"
    t.bigint "designation_id"
    t.string "gender"
    t.string "city"
    t.string "country"
    t.index ["company_id", "email"], name: "index_users_on_company_id_and_email"
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["department_id"], name: "index_users_on_department_id"
    t.index ["designation_id"], name: "index_users_on_designation_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  create_table "users_benefits", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.float "amount", null: false
    t.bigint "benefit_id", null: false
    t.bigint "user_id", null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sequence_num", null: false
    t.index ["benefit_id"], name: "index_users_benefits_on_benefit_id"
    t.index ["company_id", "sequence_num"], name: "index_users_benefits_on_company_id_and_sequence_num", unique: true
    t.index ["company_id", "user_id"], name: "index_users_benefits_on_company_id_and_user_id"
    t.index ["company_id"], name: "index_users_benefits_on_company_id"
    t.index ["user_id"], name: "index_users_benefits_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "notifications", "companies"
end
