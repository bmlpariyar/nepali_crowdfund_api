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

ActiveRecord::Schema[7.2].define(version: 2025_05_24_021025) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "campaigns", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "category_id", null: false
    t.string "title", null: false
    t.text "story"
    t.decimal "funding_goal", null: false
    t.decimal "current_amount", default: "0.0"
    t.datetime "deadline"
    t.string "status", default: "active"
    t.string "slug"
    t.string "image_url"
    t.string "video_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_campaigns_on_category_id"
    t.index ["user_id"], name: "index_campaigns_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.string "slug"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_categories_on_name", unique: true
    t.index ["slug"], name: "index_categories_on_slug", unique: true
  end

  create_table "donations", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "campaign_id", null: false
    t.decimal "amount"
    t.string "status", default: "pending"
    t.boolean "is_anonymous", default: false
    t.string "payment_gateway_transaction_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id"], name: "index_donations_on_campaign_id"
    t.index ["user_id"], name: "index_donations_on_user_id"
  end

  create_table "user_profiles", force: :cascade do |t|
    t.text "bio"
    t.string "location"
    t.string "website_url"
    t.string "profile_picture_url"
    t.date "date_of_birth"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_user_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "full_name"
    t.string "email"
    t.string "password_digest"
    t.boolean "is_admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "campaigns", "categories"
  add_foreign_key "campaigns", "users"
  add_foreign_key "donations", "campaigns"
  add_foreign_key "donations", "users"
  add_foreign_key "user_profiles", "users"
end
