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

ActiveRecord::Schema[8.1].define(version: 2025_12_09_192403) do
  create_table "accounts", force: :cascade do |t|
    t.string "account_type"
    t.string "address", null: false
    t.decimal "balance_usd", precision: 18, scale: 2, default: "0.0"
    t.string "blockchain"
    t.datetime "created_at", null: false
    t.text "defi_positions"
    t.text "description"
    t.string "ens_name"
    t.json "extensions"
    t.string "group"
    t.datetime "last_synced_at"
    t.string "name"
    t.decimal "protocol_balance_usd", precision: 20, scale: 2, default: "0.0"
    t.string "status", default: "active", null: false
    t.text "sync_error"
    t.string "sync_status"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.decimal "wallet_balance_usd", precision: 20, scale: 2, default: "0.0"
    t.index ["blockchain"], name: "index_accounts_on_blockchain"
    t.index ["status"], name: "index_accounts_on_status"
    t.index ["user_id", "address"], name: "index_accounts_on_user_id_and_address", unique: true
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "accounts", "users"
  add_foreign_key "sessions", "users"
end
