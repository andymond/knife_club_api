# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_05_26_181635) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "cookbooks", force: :cascade do |t|
    t.string "name"
    t.boolean "public", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recipes", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "public", default: false
    t.bigint "section_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["section_id"], name: "index_recipes_on_section_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sections", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "cookbook_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cookbook_id"], name: "index_sections_on_cookbook_id"
  end

  create_table "user_api_sessions", force: :cascade do |t|
    t.bigint "user_id"
    t.string "api_token_digest"
    t.integer "failed_login_count"
    t.datetime "lock_expires_at"
    t.datetime "api_token_last_verified"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_api_sessions_on_user_id"
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "cookbook_id", null: false
    t.index ["cookbook_id"], name: "index_user_roles_on_cookbook_id"
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.string "email", null: false
    t.string "crypted_password"
    t.string "salt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_token_expires_at"
    t.datetime "reset_password_email_sent_at"
    t.integer "access_count_to_reset_password_page", default: 0
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
  end

  add_foreign_key "recipes", "sections"
  add_foreign_key "sections", "cookbooks"
  add_foreign_key "user_api_sessions", "users"
  add_foreign_key "user_roles", "cookbooks"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
end
