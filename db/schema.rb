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

ActiveRecord::Schema[7.2].define(version: 2025_07_14_141740) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
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

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "campaign_views", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "campaign_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "user_id"], name: "index_campaign_views_on_campaign_id_and_user_id", unique: true
    t.index ["campaign_id"], name: "index_campaign_views_on_campaign_id"
    t.index ["user_id"], name: "index_campaign_views_on_user_id"
  end

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
    t.string "address"
    t.float "latitude"
    t.float "longitude"
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

  create_table "chat_messages", force: :cascade do |t|
    t.bigint "campaign_id", null: false
    t.bigint "user_id", null: false
    t.text "message", null: false
    t.string "sender_type", null: false
    t.boolean "read", default: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "conversation_id", null: false
    t.index ["campaign_id", "created_at"], name: "index_chat_messages_on_campaign_id_and_created_at"
    t.index ["campaign_id", "read"], name: "index_chat_messages_on_campaign_id_and_read"
    t.index ["campaign_id"], name: "index_chat_messages_on_campaign_id"
    t.index ["conversation_id"], name: "index_chat_messages_on_conversation_id"
    t.index ["user_id", "created_at"], name: "index_chat_messages_on_user_id_and_created_at"
    t.index ["user_id"], name: "index_chat_messages_on_user_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.bigint "campaign_id", null: false
    t.bigint "creator_id", null: false
    t.bigint "donor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["campaign_id", "creator_id", "donor_id"], name: "index_conversations_on_campaign_id_and_creator_id_and_donor_id", unique: true
    t.index ["campaign_id"], name: "index_conversations_on_campaign_id"
    t.index ["creator_id"], name: "index_conversations_on_creator_id"
    t.index ["donor_id"], name: "index_conversations_on_donor_id"
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
    t.string "support_message"
    t.index ["campaign_id"], name: "index_donations_on_campaign_id"
    t.index ["user_id"], name: "index_donations_on_user_id"
  end

  create_table "update_messages", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "campaign_id", null: false
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.index ["campaign_id"], name: "index_update_messages_on_campaign_id"
    t.index ["user_id"], name: "index_update_messages_on_user_id"
  end

  create_table "user_profiles", force: :cascade do |t|
    t.text "bio"
    t.string "location"
    t.string "website_url"
    t.date "date_of_birth"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "latitude"
    t.float "longitude"
    t.index ["user_id"], name: "index_user_profiles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "full_name"
    t.string "email"
    t.string "password_digest"
    t.boolean "is_admin", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_active", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "campaign_views", "campaigns"
  add_foreign_key "campaign_views", "users"
  add_foreign_key "campaigns", "categories"
  add_foreign_key "campaigns", "users"
  add_foreign_key "chat_messages", "campaigns"
  add_foreign_key "chat_messages", "conversations"
  add_foreign_key "chat_messages", "users"
  add_foreign_key "conversations", "campaigns"
  add_foreign_key "conversations", "users", column: "creator_id"
  add_foreign_key "conversations", "users", column: "donor_id"
  add_foreign_key "donations", "campaigns"
  add_foreign_key "donations", "users"
  add_foreign_key "update_messages", "campaigns"
  add_foreign_key "update_messages", "users"
  add_foreign_key "user_profiles", "users"
end
