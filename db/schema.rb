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

ActiveRecord::Schema[7.1].define(version: 2026_04_15_000500) do
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

  create_table "ai_chat_messages", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "role"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_ai_chat_messages_on_user_id"
  end

  create_table "analytics_events", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "session_id"
    t.string "name", null: false
    t.datetime "occurred_at", null: false
    t.json "properties", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "occurred_at"], name: "index_analytics_events_on_name_and_occurred_at"
    t.index ["session_id", "name"], name: "index_analytics_events_on_session_id_and_name"
    t.index ["session_id"], name: "index_analytics_events_on_session_id"
    t.index ["user_id", "name", "occurred_at"], name: "index_analytics_events_on_user_id_and_name_and_occurred_at"
    t.index ["user_id"], name: "index_analytics_events_on_user_id"
  end

  create_table "authors", force: :cascade do |t|
    t.string "name"
    t.string "bio"
    t.string "dob"
    t.integer "books_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "badges", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.string "description"
    t.string "image_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_badges_on_user_id"
  end

  create_table "books", force: :cascade do |t|
    t.string "title"
    t.string "image_url"
    t.integer "author_id"
    t.text "description"
    t.integer "page_length"
    t.integer "year"
    t.integer "library_id"
    t.string "genre"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.integer "post_id"
    t.integer "commenter_id"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "followrequests", force: :cascade do |t|
    t.integer "sender_id"
    t.integer "recipient_id"
    t.string "status", default: "pending"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "likes", force: :cascade do |t|
    t.integer "post_id"
    t.integer "liked_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "recipient_id"
    t.integer "actor_id"
    t.string "action"
    t.string "notifiable_type"
    t.integer "notifiable_id"
    t.boolean "read", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "posts", force: :cascade do |t|
    t.integer "creator_id"
    t.text "content"
    t.integer "book_id"
    t.integer "likes_count"
    t.integer "comments_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "poll_data"
  end

  create_table "readings", force: :cascade do |t|
    t.integer "user_id"
    t.integer "book_id"
    t.string "status"
    t.decimal "rating", precision: 2, scale: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "progress"
    t.text "review"
    t.boolean "is_private", default: false
    t.index ["user_id", "book_id"], name: "index_readings_on_user_id_and_book_id", unique: true
  end

  create_table "renous", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "post_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id"], name: "index_renous_on_post_id"
    t.index ["user_id", "post_id"], name: "index_renous_on_user_id_and_post_id", unique: true
    t.index ["user_id"], name: "index_renous_on_user_id"
  end

  create_table "search_histories", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "query"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_search_histories_on_user_id"
  end

  create_table "session_participants", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "session_id", null: false
    t.datetime "join_time", null: false
    t.datetime "leave_time"
    t.boolean "completed", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["session_id", "leave_time"], name: "index_session_participants_on_session_id_and_leave_time"
    t.index ["session_id", "user_id"], name: "index_session_participants_on_session_id_and_user_id", unique: true
    t.index ["session_id"], name: "index_session_participants_on_session_id"
    t.index ["user_id"], name: "index_session_participants_on_user_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "host_user_id", null: false
    t.integer "duration", null: false
    t.string "mode", default: "silent", null: false
    t.string "status", default: "NOT_STARTED", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["host_user_id"], name: "index_sessions_on_host_user_id"
    t.index ["status"], name: "index_sessions_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "name"
    t.string "username"
    t.string "avatar"
    t.text "bio"
    t.integer "posts_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "banner"
    t.boolean "is_private", default: false
    t.datetime "last_active"
    t.integer "total_reading_time", default: 0, null: false
    t.integer "sessions_completed", default: 0, null: false
    t.text "preferred_genres", default: "[]"
    t.string "reading_frequency"
    t.string "social_reading_preference"
    t.datetime "recommendation_onboarding_completed_at"
    t.datetime "recommendation_onboarding_skipped_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "ai_chat_messages", "users"
  add_foreign_key "analytics_events", "sessions"
  add_foreign_key "analytics_events", "users"
  add_foreign_key "badges", "users"
  add_foreign_key "renous", "posts"
  add_foreign_key "renous", "users"
  add_foreign_key "search_histories", "users"
  add_foreign_key "session_participants", "sessions"
  add_foreign_key "session_participants", "users"
  add_foreign_key "sessions", "users", column: "host_user_id"
end
