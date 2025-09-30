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

ActiveRecord::Schema[8.1].define(version: 2025_09_30_042058) do
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

  create_table "analytics", force: :cascade do |t|
    t.string "campaign"
    t.datetime "created_at", null: false
    t.string "event_type", null: false
    t.bigint "lead_id", null: false
    t.string "medium"
    t.jsonb "metadata", default: {}
    t.string "source"
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_analytics_on_created_at"
    t.index ["event_type"], name: "index_analytics_on_event_type"
    t.index ["lead_id", "event_type"], name: "index_analytics_on_lead_id_and_event_type"
    t.index ["lead_id"], name: "index_analytics_on_lead_id"
    t.index ["source"], name: "index_analytics_on_source"
  end

  create_table "blog_authors", force: :cascade do |t|
    t.text "bio"
    t.string "company"
    t.datetime "created_at", null: false
    t.string "email"
    t.text "expertise", default: [], array: true
    t.integer "follower_count", default: 0
    t.string "location"
    t.string "name"
    t.string "slug"
    t.jsonb "social_media"
    t.string "title"
    t.datetime "updated_at", null: false
    t.boolean "verified", default: false
    t.string "website"
    t.index ["slug"], name: "index_blog_authors_on_slug", unique: true
  end

  create_table "blog_categories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name"
    t.bigint "parent_id"
    t.integer "post_count", default: 0
    t.string "slug"
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_blog_categories_on_parent_id"
    t.index ["slug"], name: "index_blog_categories_on_slug", unique: true
  end

  create_table "blog_comments", force: :cascade do |t|
    t.string "author_email", null: false
    t.string "author_name", null: false
    t.string "author_website"
    t.bigint "blog_post_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.bigint "parent_id"
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["blog_post_id"], name: "index_blog_comments_on_blog_post_id"
    t.index ["created_at"], name: "index_blog_comments_on_created_at"
    t.index ["parent_id"], name: "index_blog_comments_on_parent_id"
    t.index ["status"], name: "index_blog_comments_on_status"
  end

  create_table "blog_media", force: :cascade do |t|
    t.string "alt_text"
    t.text "caption"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.integer "file_size"
    t.string "media_type"
    t.jsonb "metadata"
    t.datetime "updated_at", null: false
  end

  create_table "blog_media_attachments", force: :cascade do |t|
    t.bigint "blog_media_id", null: false
    t.bigint "blog_post_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blog_media_id"], name: "index_blog_media_attachments_on_blog_media_id"
    t.index ["blog_post_id"], name: "index_blog_media_attachments_on_blog_post_id"
  end

  create_table "blog_post_tags", force: :cascade do |t|
    t.bigint "blog_post_id", null: false
    t.bigint "blog_tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blog_post_id"], name: "index_blog_post_tags_on_blog_post_id"
    t.index ["blog_tag_id"], name: "index_blog_post_tags_on_blog_tag_id"
  end

  create_table "blog_posts", force: :cascade do |t|
    t.bigint "author_id"
    t.string "author_type"
    t.integer "blog_comments_count", default: 0, null: false
    t.string "canonical_url"
    t.bigint "category_id"
    t.string "city"
    t.text "content"
    t.integer "content_layout", default: 0
    t.string "country_code"
    t.datetime "created_at", null: false
    t.text "excerpt"
    t.boolean "featured"
    t.integer "hero_style", default: 0
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "meta_description"
    t.string "meta_keywords"
    t.string "meta_title"
    t.datetime "published_at"
    t.integer "reading_time"
    t.string "region"
    t.integer "shares_count", default: 0
    t.string "slug"
    t.string "status"
    t.string "title"
    t.datetime "updated_at", null: false
    t.integer "views_count", default: 0
    t.index ["author_id"], name: "index_blog_posts_on_author_id"
    t.index ["author_type", "author_id"], name: "index_blog_posts_on_author_type_and_author_id"
    t.index ["category_id"], name: "index_blog_posts_on_category_id"
    t.index ["slug"], name: "index_blog_posts_on_slug", unique: true
  end

  create_table "blog_related_posts", force: :cascade do |t|
    t.bigint "blog_post_id", null: false
    t.datetime "created_at", null: false
    t.bigint "related_post_id", null: false
    t.datetime "updated_at", null: false
    t.index ["blog_post_id"], name: "index_blog_related_posts_on_blog_post_id"
    t.index ["related_post_id"], name: "index_blog_related_posts_on_related_post_id"
  end

  create_table "blog_subscriptions", force: :cascade do |t|
    t.boolean "active", default: true
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_blog_subscriptions_on_email", unique: true
  end

  create_table "blog_tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.string "slug"
    t.datetime "updated_at", null: false
    t.integer "usage_count", default: 0
    t.index ["slug"], name: "index_blog_tags_on_slug", unique: true
  end

  create_table "conversion_events", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "event_name", null: false
    t.bigint "lead_id", null: false
    t.integer "time_to_convert"
    t.datetime "updated_at", null: false
    t.decimal "value", precision: 10, scale: 2
    t.index ["created_at"], name: "index_conversion_events_on_created_at"
    t.index ["event_name"], name: "index_conversion_events_on_event_name"
    t.index ["lead_id", "event_name"], name: "index_conversion_events_on_lead_id_and_event_name"
    t.index ["lead_id"], name: "index_conversion_events_on_lead_id"
  end

  create_table "crm_syncs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "crm_id"
    t.string "crm_system", null: false
    t.datetime "last_synced_at"
    t.bigint "lead_id", null: false
    t.jsonb "metadata", default: {}
    t.text "sync_error"
    t.string "sync_status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["crm_id"], name: "index_crm_syncs_on_crm_id"
    t.index ["last_synced_at"], name: "index_crm_syncs_on_last_synced_at"
    t.index ["lead_id", "crm_system"], name: "index_crm_syncs_on_lead_id_and_crm_system", unique: true
    t.index ["lead_id"], name: "index_crm_syncs_on_lead_id"
    t.index ["sync_status"], name: "index_crm_syncs_on_sync_status"
  end

  create_table "email_sequences", force: :cascade do |t|
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.integer "current_step", default: 0, null: false
    t.bigint "lead_id", null: false
    t.jsonb "metadata", default: {}
    t.string "sequence_name", null: false
    t.datetime "started_at"
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.index ["lead_id", "sequence_name"], name: "index_email_sequences_on_lead_id_and_sequence_name", unique: true
    t.index ["lead_id"], name: "index_email_sequences_on_lead_id"
    t.index ["started_at"], name: "index_email_sequences_on_started_at"
    t.index ["status"], name: "index_email_sequences_on_status"
  end

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.datetime "created_at"
    t.string "scope"
    t.string "slug", null: false
    t.integer "sluggable_id", null: false
    t.string "sluggable_type", limit: 50
    t.index ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true
    t.index ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type"
    t.index ["sluggable_type", "sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_type_and_sluggable_id"
  end

  create_table "leads", force: :cascade do |t|
    t.string "assigned_to"
    t.string "budget", null: false
    t.decimal "budget_score", precision: 5, scale: 2, default: "0.0"
    t.string "company"
    t.decimal "complexity_score", precision: 5, scale: 2, default: "0.0"
    t.datetime "contacted_at"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.integer "lead_status", default: 0, null: false
    t.jsonb "metadata", default: {}
    t.text "notes"
    t.string "phone"
    t.string "preferred_contact_method", default: "email"
    t.text "project_description", null: false
    t.string "project_type", null: false
    t.datetime "qualified_at"
    t.decimal "quality_score", precision: 5, scale: 2, default: "0.0"
    t.decimal "score", precision: 5, scale: 2, default: "0.0"
    t.string "source", default: "website"
    t.string "timeline", null: false
    t.decimal "timeline_score", precision: 5, scale: 2, default: "0.0"
    t.datetime "updated_at", null: false
    t.string "website"
    t.index ["budget"], name: "index_leads_on_budget"
    t.index ["contacted_at"], name: "index_leads_on_contacted_at"
    t.index ["created_at"], name: "index_leads_on_created_at"
    t.index ["email"], name: "index_leads_on_email", unique: true
    t.index ["lead_status"], name: "index_leads_on_lead_status"
    t.index ["project_type"], name: "index_leads_on_project_type"
    t.index ["score"], name: "index_leads_on_score"
    t.index ["source"], name: "index_leads_on_source"
    t.index ["timeline"], name: "index_leads_on_timeline"
  end

  create_table "project_services", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "project_id", null: false
    t.bigint "service_id", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "service_id"], name: "index_project_services_on_project_and_service", unique: true
    t.index ["project_id"], name: "index_project_services_on_project_id"
    t.index ["service_id"], name: "index_project_services_on_service_id"
  end

  create_table "project_technologies", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "project_id", null: false
    t.bigint "technology_id", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id", "technology_id"], name: "index_project_technologies_on_project_and_technology", unique: true
    t.index ["project_id"], name: "index_project_technologies_on_project_id"
    t.index ["technology_id"], name: "index_project_technologies_on_technology_id"
  end

  create_table "projects", force: :cascade do |t|
    t.string "client_name", null: false
    t.date "completion_date"
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.integer "duration_months"
    t.boolean "featured", default: false, null: false
    t.string "github_url"
    t.string "project_url"
    t.string "slug", null: false
    t.integer "status", default: 0, null: false
    t.integer "team_size"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.index ["completion_date"], name: "index_projects_on_completion_date"
    t.index ["featured"], name: "index_projects_on_featured"
    t.index ["slug"], name: "index_projects_on_slug", unique: true
    t.index ["status"], name: "index_projects_on_status"
  end

  create_table "services", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.text "features"
    t.string "icon_class"
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_services_on_slug", unique: true
  end

  create_table "technologies", force: :cascade do |t|
    t.string "category", null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "icon_class"
    t.string "name", null: false
    t.datetime "updated_at", null: false
    t.index ["category"], name: "index_technologies_on_category"
    t.index ["name"], name: "index_technologies_on_name", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin", default: false
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", null: false
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "analytics", "leads"
  add_foreign_key "blog_categories", "blog_categories", column: "parent_id"
  add_foreign_key "blog_comments", "blog_comments", column: "parent_id"
  add_foreign_key "blog_comments", "blog_posts"
  add_foreign_key "blog_media_attachments", "blog_media", column: "blog_media_id"
  add_foreign_key "blog_media_attachments", "blog_posts"
  add_foreign_key "blog_post_tags", "blog_posts"
  add_foreign_key "blog_post_tags", "blog_tags"
  add_foreign_key "blog_posts", "blog_categories", column: "category_id"
  add_foreign_key "blog_related_posts", "blog_posts"
  add_foreign_key "blog_related_posts", "blog_posts", column: "related_post_id"
  add_foreign_key "conversion_events", "leads"
  add_foreign_key "crm_syncs", "leads"
  add_foreign_key "email_sequences", "leads"
  add_foreign_key "project_services", "projects"
  add_foreign_key "project_services", "services"
  add_foreign_key "project_technologies", "projects"
  add_foreign_key "project_technologies", "technologies"
end
