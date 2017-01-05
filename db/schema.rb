# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20170102124200) do

  create_table "accounts", force: :cascade do |t|
    t.string   "name",                    limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "can_view_support_desk",               default: false, null: false
    t.boolean  "can_view_ad_spend",                   default: true,  null: false
    t.boolean  "can_view_sdks",                       default: false, null: false
    t.boolean  "can_view_storewide_sdks",             default: false
    t.boolean  "can_view_exports",                    default: true
    t.boolean  "is_admin_account",                    default: false
    t.boolean  "can_view_ios_live_scan"
    t.integer  "seats_count",             limit: 4,   default: 5
    t.boolean  "can_view_ad_attribution",             default: false
  end

  add_index "accounts", ["name"], name: "index_accounts_on_name", using: :btree

  create_table "activities", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "happened_at"
  end

  create_table "ad_platforms", force: :cascade do |t|
    t.string   "platform",   limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "android_app_categories", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "android_app_categories", ["name"], name: "index_android_app_categories_on_name", using: :btree

  create_table "android_app_categories_snapshots", force: :cascade do |t|
    t.integer  "android_app_category_id", limit: 4
    t.integer  "android_app_snapshot_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "kind",                    limit: 4
  end

  add_index "android_app_categories_snapshots", ["android_app_category_id"], name: "index_android_app_category_id", using: :btree
  add_index "android_app_categories_snapshots", ["android_app_snapshot_id", "android_app_category_id"], name: "index_android_app_snapshot_id_category_id", using: :btree

  create_table "android_app_snapshot_backups", force: :cascade do |t|
    t.string   "name",                             limit: 191
    t.integer  "price",                            limit: 4
    t.integer  "size",                             limit: 8
    t.date     "updated"
    t.string   "seller_url",                       limit: 191
    t.string   "version",                          limit: 191
    t.date     "released"
    t.text     "description",                      limit: 65535
    t.integer  "android_app_id",                   limit: 4
    t.integer  "google_plus_likes",                limit: 4
    t.boolean  "top_dev"
    t.boolean  "in_app_purchases"
    t.string   "required_android_version",         limit: 191
    t.string   "content_rating",                   limit: 191
    t.string   "seller",                           limit: 191
    t.decimal  "ratings_all_stars",                              precision: 3, scale: 2
    t.integer  "ratings_all_count",                limit: 4
    t.integer  "status",                           limit: 4
    t.integer  "android_app_snapshot_job_id",      limit: 4
    t.integer  "in_app_purchase_min",              limit: 4
    t.integer  "in_app_purchase_max",              limit: 4
    t.integer  "downloads_min",                    limit: 8
    t.integer  "downloads_max",                    limit: 8
    t.string   "icon_url_300x300",                 limit: 191
    t.string   "developer_google_play_identifier", limit: 191
    t.boolean  "apk_access_forbidden"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "android_app_snapshot_backups", ["android_app_id", "name"], name: "index_android_app_snapshot_backups_on_android_app_id_and_name", using: :btree
  add_index "android_app_snapshot_backups", ["android_app_id", "released"], name: "index_android_app_snapshot_bck_app_released", using: :btree
  add_index "android_app_snapshot_backups", ["android_app_snapshot_job_id"], name: "index_android_app_snapshot_bck_job_id", using: :btree
  add_index "android_app_snapshot_backups", ["developer_google_play_identifier"], name: "index_android_app_snapshot_bck_dev_id", using: :btree
  add_index "android_app_snapshot_backups", ["downloads_min"], name: "index_android_app_snapshot_bck_dwnld_min", using: :btree
  add_index "android_app_snapshot_backups", ["name"], name: "index_android_app_snapshot_backups_on_name", using: :btree
  add_index "android_app_snapshot_backups", ["released"], name: "index_android_app_snapshot_backups_on_released", using: :btree

  create_table "android_app_snapshot_exceptions", force: :cascade do |t|
    t.integer  "android_app_snapshot_id",     limit: 4
    t.text     "name",                        limit: 65535
    t.text     "backtrace",                   limit: 65535
    t.integer  "try",                         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "android_app_snapshot_job_id", limit: 4
  end

  add_index "android_app_snapshot_exceptions", ["android_app_snapshot_id"], name: "index_android_app_snapshot_exceptions_on_android_app_snapshot_id", using: :btree
  add_index "android_app_snapshot_exceptions", ["android_app_snapshot_job_id"], name: "index_android_app_snapshot_job_id", using: :btree

  create_table "android_app_snapshot_jobs", force: :cascade do |t|
    t.text     "notes",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "android_app_snapshots", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                             limit: 191
    t.integer  "price",                            limit: 4
    t.integer  "size",                             limit: 8
    t.date     "updated"
    t.string   "seller_url",                       limit: 191
    t.string   "version",                          limit: 191
    t.date     "released"
    t.text     "description",                      limit: 65535
    t.integer  "android_app_id",                   limit: 4
    t.integer  "google_plus_likes",                limit: 4
    t.boolean  "top_dev"
    t.boolean  "in_app_purchases"
    t.string   "required_android_version",         limit: 191
    t.string   "content_rating",                   limit: 191
    t.string   "seller",                           limit: 191
    t.decimal  "ratings_all_stars",                              precision: 3, scale: 2
    t.integer  "ratings_all_count",                limit: 4
    t.integer  "status",                           limit: 4
    t.integer  "android_app_snapshot_job_id",      limit: 4
    t.integer  "in_app_purchase_min",              limit: 4
    t.integer  "in_app_purchase_max",              limit: 4
    t.integer  "downloads_min",                    limit: 8
    t.integer  "downloads_max",                    limit: 8
    t.string   "icon_url_300x300",                 limit: 191
    t.string   "developer_google_play_identifier", limit: 191
    t.boolean  "apk_access_forbidden"
  end

  add_index "android_app_snapshots", ["android_app_id", "name"], name: "index_android_app_id_and_name", using: :btree
  add_index "android_app_snapshots", ["android_app_id", "released"], name: "index_android_app_id_and_released", using: :btree
  add_index "android_app_snapshots", ["android_app_id"], name: "index_android_app_id", using: :btree
  add_index "android_app_snapshots", ["android_app_snapshot_job_id"], name: "index_android_app_snapshot_job_id", using: :btree
  add_index "android_app_snapshots", ["android_app_snapshot_job_id"], name: "index_android_app_snapshots_on_android_app_snapshot_job_id", using: :btree
  add_index "android_app_snapshots", ["apk_access_forbidden"], name: "index_apk_access_forbidden", using: :btree
  add_index "android_app_snapshots", ["developer_google_play_identifier"], name: "index_developer_google_play_identifier", using: :btree
  add_index "android_app_snapshots", ["downloads_min"], name: "index_downloads_min", using: :btree
  add_index "android_app_snapshots", ["name"], name: "index_name", using: :btree
  add_index "android_app_snapshots", ["released"], name: "index_released", using: :btree

  create_table "android_app_snapshots_scr_shts", force: :cascade do |t|
    t.string   "url",                     limit: 191
    t.integer  "position",                limit: 4
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.integer  "android_app_snapshot_id", limit: 4
  end

  add_index "android_app_snapshots_scr_shts", ["android_app_snapshot_id"], name: "index_android_app_snapshots_scr_shts_on_android_app_snapshot_id", using: :btree

  create_table "android_apps", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "app_identifier",                 limit: 191
    t.integer  "app_id",                         limit: 4
    t.integer  "newest_android_app_snapshot_id", limit: 4
    t.integer  "user_base",                      limit: 4
    t.integer  "mobile_priority",                limit: 4
    t.integer  "newest_apk_snapshot_id",         limit: 4
    t.integer  "display_type",                   limit: 4,   default: 0
    t.integer  "android_developer_id",           limit: 4
  end

  add_index "android_apps", ["android_developer_id"], name: "index_android_apps_on_android_developer_id", using: :btree
  add_index "android_apps", ["app_identifier"], name: "index_android_apps_on_app_identifier", unique: true, using: :btree
  add_index "android_apps", ["display_type"], name: "index_android_apps_on_display_type", using: :btree
  add_index "android_apps", ["mobile_priority"], name: "index_android_apps_on_mobile_priority", using: :btree
  add_index "android_apps", ["newest_android_app_snapshot_id"], name: "index_android_apps_on_newest_android_app_snapshot_id", using: :btree
  add_index "android_apps", ["newest_apk_snapshot_id"], name: "index_android_apps_on_newest_apk_snapshot_id", using: :btree
  add_index "android_apps", ["user_base"], name: "index_android_apps_on_user_base", using: :btree

  create_table "android_apps_websites", force: :cascade do |t|
    t.integer  "android_app_id", limit: 4
    t.integer  "website_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "android_apps_websites", ["android_app_id"], name: "index_android_apps_websites_on_android_app_id", using: :btree
  add_index "android_apps_websites", ["website_id", "android_app_id"], name: "index_android_apps_websites_on_website_id_and_android_app_id", using: :btree

  create_table "android_developers", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.string   "identifier", limit: 191
    t.integer  "company_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "android_developers", ["company_id"], name: "index_android_developers_on_company_id", using: :btree
  add_index "android_developers", ["identifier"], name: "index_android_developers_on_identifier", unique: true, using: :btree
  add_index "android_developers", ["name"], name: "index_android_developers_on_name", using: :btree

  create_table "android_developers_websites", force: :cascade do |t|
    t.integer  "android_developer_id", limit: 4
    t.integer  "website_id",           limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_valid",                       default: true
  end

  add_index "android_developers_websites", ["android_developer_id", "is_valid"], name: "android_developers_websites_is_valid", using: :btree
  add_index "android_developers_websites", ["android_developer_id", "website_id"], name: "android_dev_id_and_website_id", using: :btree
  add_index "android_developers_websites", ["website_id"], name: "index_android_developers_websites_on_website_id", using: :btree

  create_table "android_fb_ad_appearances", force: :cascade do |t|
    t.string   "aws_assignment_identifier", limit: 191
    t.string   "hit_identifier",            limit: 191
    t.integer  "m_turk_worker_id",          limit: 4
    t.integer  "android_app_id",            limit: 4
    t.string   "heroku_identifier",         limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "android_fb_ad_appearances", ["android_app_id"], name: "index_android_fb_ad_appearances_on_android_app_id", using: :btree
  add_index "android_fb_ad_appearances", ["aws_assignment_identifier"], name: "index_android_fb_ad_appearances_on_aws_assignment_identifier", using: :btree
  add_index "android_fb_ad_appearances", ["heroku_identifier"], name: "index_android_fb_ad_appearances_on_heroku_identifier", using: :btree
  add_index "android_fb_ad_appearances", ["hit_identifier"], name: "index_android_fb_ad_appearances_on_hit_identifier", using: :btree
  add_index "android_fb_ad_appearances", ["m_turk_worker_id"], name: "index_android_fb_ad_appearances_on_m_turk_worker_id", using: :btree

  create_table "android_packages", force: :cascade do |t|
    t.string   "package_name",        limit: 191
    t.integer  "apk_snapshot_id",     limit: 4
    t.integer  "android_package_tag", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "identified"
    t.boolean  "not_useful"
  end

  add_index "android_packages", ["android_package_tag"], name: "index_android_packages_on_android_package_tag", using: :btree
  add_index "android_packages", ["apk_snapshot_id"], name: "index_android_packages_on_apk_snapshot_id", using: :btree
  add_index "android_packages", ["package_name"], name: "index_android_packages_on_package_name", using: :btree

  create_table "android_sdk_companies", force: :cascade do |t|
    t.string   "name",              limit: 191
    t.string   "website",           limit: 191
    t.string   "favicon",           limit: 191
    t.boolean  "flagged",                       default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "open_source",                   default: false
    t.integer  "parent_company_id", limit: 4
    t.boolean  "is_parent"
  end

  add_index "android_sdk_companies", ["flagged"], name: "index_android_sdk_companies_on_flagged", using: :btree
  add_index "android_sdk_companies", ["name", "flagged", "is_parent"], name: "index_android_sdk_companies_name_flagged_is_parent", using: :btree
  add_index "android_sdk_companies", ["name"], name: "index_android_sdk_companies_on_name", using: :btree
  add_index "android_sdk_companies", ["open_source"], name: "android_sdk_companies_open_source_index", using: :btree
  add_index "android_sdk_companies", ["parent_company_id"], name: "android_sdk_companies_parent_company_index", using: :btree
  add_index "android_sdk_companies", ["website"], name: "index_android_sdk_companies_on_website", using: :btree

  create_table "android_sdk_companies_android_apps", force: :cascade do |t|
    t.integer  "android_sdk_company_id", limit: 4
    t.integer  "android_app_id",         limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "android_sdk_companies_android_apps", ["android_app_id", "android_sdk_company_id"], name: "index_android_app_id_android_sdk_company_id", using: :btree
  add_index "android_sdk_companies_android_apps", ["android_sdk_company_id"], name: "android_sdk_company_id", using: :btree

  create_table "android_sdk_companies_apk_snapshots", force: :cascade do |t|
    t.integer  "android_sdk_company_id", limit: 4
    t.integer  "apk_snapshot_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "android_sdk_companies_apk_snapshots", ["android_sdk_company_id"], name: "android_sdk_company_id", using: :btree
  add_index "android_sdk_companies_apk_snapshots", ["apk_snapshot_id", "android_sdk_company_id"], name: "index_apk_snapshot_id_android_sdk_company_id2", using: :btree
  add_index "android_sdk_companies_apk_snapshots", ["apk_snapshot_id", "android_sdk_company_id"], name: "index_apk_snapshot_id_android_sdk_company_id_unique", unique: true, using: :btree

  create_table "android_sdk_links", force: :cascade do |t|
    t.integer  "source_sdk_id", limit: 4
    t.integer  "dest_sdk_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "android_sdk_links", ["dest_sdk_id"], name: "index_android_sdk_links_on_dest_sdk_id", using: :btree
  add_index "android_sdk_links", ["source_sdk_id"], name: "index_android_sdk_links_on_source_sdk_id", unique: true, using: :btree

  create_table "android_sdk_package_prefixes", force: :cascade do |t|
    t.string  "prefix",                 limit: 191
    t.integer "android_sdk_company_id", limit: 4
  end

  add_index "android_sdk_package_prefixes", ["android_sdk_company_id"], name: "index_android_sdk_package_prefixes_on_android_sdk_company_id", using: :btree
  add_index "android_sdk_package_prefixes", ["prefix"], name: "index_android_sdk_package_prefixes_on_prefix", using: :btree

  create_table "android_sdk_packages", force: :cascade do |t|
    t.string   "package_name",                  limit: 191
    t.integer  "android_sdk_package_prefix_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "android_sdk_packages", ["android_sdk_package_prefix_id"], name: "index_android_sdk_packages_on_android_sdk_package_prefix_id", using: :btree
  add_index "android_sdk_packages", ["package_name"], name: "index_android_sdk_packages_on_package_name", using: :btree

  create_table "android_sdk_packages_apk_snapshots", force: :cascade do |t|
    t.integer  "android_sdk_package_id", limit: 4
    t.integer  "apk_snapshot_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "android_sdk_packages_apk_snapshots", ["android_sdk_package_id"], name: "android_sdk_package_id", using: :btree
  add_index "android_sdk_packages_apk_snapshots", ["apk_snapshot_id", "android_sdk_package_id"], name: "index_apk_snapshot_id_android_sdk_package_id", using: :btree

  create_table "android_sdks", force: :cascade do |t|
    t.string   "name",                   limit: 191
    t.string   "website",                limit: 191
    t.string   "favicon",                limit: 191
    t.boolean  "flagged",                            default: false
    t.boolean  "open_source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sdk_company_id",         limit: 4
    t.integer  "github_repo_identifier", limit: 4
    t.integer  "kind",                   limit: 4
  end

  add_index "android_sdks", ["flagged"], name: "index_android_sdks_on_flagged", using: :btree
  add_index "android_sdks", ["github_repo_identifier"], name: "index_android_sdks_on_github_repo_identifier", unique: true, using: :btree
  add_index "android_sdks", ["kind"], name: "index_android_sdks_on_kind", using: :btree
  add_index "android_sdks", ["name"], name: "index_android_sdks_on_name", unique: true, using: :btree
  add_index "android_sdks", ["open_source"], name: "index_android_sdks_on_open_source", using: :btree
  add_index "android_sdks", ["sdk_company_id"], name: "index_android_sdks_on_sdk_company_id", using: :btree
  add_index "android_sdks", ["website"], name: "index_android_sdks_on_website", using: :btree

  create_table "android_sdks_apk_snapshots", force: :cascade do |t|
    t.integer  "android_sdk_id",  limit: 4
    t.integer  "apk_snapshot_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "method",          limit: 4
  end

  add_index "android_sdks_apk_snapshots", ["android_sdk_id"], name: "android_sdk_id", using: :btree
  add_index "android_sdks_apk_snapshots", ["apk_snapshot_id", "android_sdk_id", "method"], name: "index_apk_snapshot_id_sdk_id_method", unique: true, using: :btree

  create_table "api_keys", force: :cascade do |t|
    t.string   "key",        limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id", limit: 4
  end

  add_index "api_keys", ["account_id"], name: "index_api_keys_on_account_id", using: :btree
  add_index "api_keys", ["key"], name: "index_api_keys_on_key", using: :btree

  create_table "api_tokens", force: :cascade do |t|
    t.integer  "account_id",  limit: 4
    t.string   "token",       limit: 191,                null: false
    t.integer  "rate_window", limit: 4,   default: 0
    t.integer  "rate_limit",  limit: 4,   default: 2500
    t.boolean  "active",                  default: true
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "api_tokens", ["account_id"], name: "index_api_tokens_on_account_id", using: :btree
  add_index "api_tokens", ["token", "active"], name: "index_api_tokens_on_token_and_active", unique: true, using: :btree

  create_table "apk_files", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "apk_file_name",    limit: 191
    t.string   "apk_content_type", limit: 191
    t.integer  "apk_file_size",    limit: 4
    t.datetime "apk_updated_at"
    t.string   "zip_file_name",    limit: 191
    t.string   "zip_content_type", limit: 191
    t.integer  "zip_file_size",    limit: 4
    t.datetime "zip_updated_at"
  end

  create_table "apk_snapshot_exceptions", force: :cascade do |t|
    t.integer  "apk_snapshot_id",     limit: 4
    t.text     "name",                limit: 65535
    t.text     "backtrace",           limit: 65535
    t.integer  "try",                 limit: 4
    t.integer  "apk_snapshot_job_id", limit: 4
    t.integer  "google_account_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status_code",         limit: 4
  end

  add_index "apk_snapshot_exceptions", ["apk_snapshot_id"], name: "index_apk_snapshot_exceptions_on_apk_snapshot_id", using: :btree
  add_index "apk_snapshot_exceptions", ["apk_snapshot_job_id"], name: "index_apk_snapshot_exceptions_on_apk_snapshot_job_id", using: :btree
  add_index "apk_snapshot_exceptions", ["google_account_id"], name: "index_apk_snapshot_exceptions_on_google_account_id", using: :btree
  add_index "apk_snapshot_exceptions", ["status_code"], name: "index_apk_status_code", using: :btree

  create_table "apk_snapshot_jobs", force: :cascade do |t|
    t.text     "notes",            limit: 65535
    t.boolean  "is_fucked"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "job_type",         limit: 4
    t.integer  "ls_lookup_code",   limit: 4
    t.integer  "ls_download_code", limit: 4
  end

  add_index "apk_snapshot_jobs", ["job_type"], name: "index_apk_snapshot_jobs_on_job_type", using: :btree

  create_table "apk_snapshot_scrape_exceptions", force: :cascade do |t|
    t.integer  "apk_snapshot_job_id", limit: 4
    t.text     "error",               limit: 65535
    t.text     "backtrace",           limit: 65535
    t.integer  "android_app_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "apk_snapshot_scrape_exceptions", ["android_app_id"], name: "index_apk_snapshot_scrape_exceptions_on_android_app_id", using: :btree
  add_index "apk_snapshot_scrape_exceptions", ["apk_snapshot_job_id"], name: "index_apk_snapshot_scrape_exceptions_on_apk_snapshot_job_id", using: :btree

  create_table "apk_snapshot_scrape_failures", force: :cascade do |t|
    t.integer  "android_app_id",      limit: 4
    t.integer  "reason",              limit: 4
    t.text     "scrape_content",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "version",             limit: 191
    t.integer  "apk_snapshot_job_id", limit: 4
  end

  add_index "apk_snapshot_scrape_failures", ["android_app_id"], name: "index_apk_snapshot_scrape_failures_on_android_app_id", using: :btree
  add_index "apk_snapshot_scrape_failures", ["apk_snapshot_job_id"], name: "index_apk_snapshot_scrape_failures_on_apk_snapshot_job_id", using: :btree

  create_table "apk_snapshots", force: :cascade do |t|
    t.string   "version",             limit: 191
    t.integer  "google_account_id",   limit: 4
    t.integer  "android_app_id",      limit: 4
    t.float    "download_time",       limit: 24
    t.float    "unpack_time",         limit: 24
    t.integer  "status",              limit: 4
    t.integer  "apk_snapshot_job_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "try",                 limit: 4
    t.text     "auth_token",          limit: 65535
    t.integer  "micro_proxy_id",      limit: 4
    t.integer  "last_device",         limit: 4
    t.integer  "apk_file_id",         limit: 4
    t.integer  "scan_status",         limit: 4
    t.datetime "last_updated"
    t.integer  "scan_version",        limit: 4
    t.integer  "version_code",        limit: 4
    t.datetime "first_valid_date"
    t.datetime "good_as_of_date"
    t.datetime "last_scanned"
    t.integer  "region",              limit: 4
  end

  add_index "apk_snapshots", ["android_app_id", "scan_status", "good_as_of_date"], name: "index_android_app_id_scan_status_good_as_of_date", using: :btree
  add_index "apk_snapshots", ["android_app_id"], name: "index_apk_snapshots_on_android_app_id", using: :btree
  add_index "apk_snapshots", ["apk_file_id"], name: "index_apk_snapshots_on_apk_file_id", using: :btree
  add_index "apk_snapshots", ["apk_snapshot_job_id"], name: "index_apk_snapshots_on_apk_snapshot_job_id", using: :btree
  add_index "apk_snapshots", ["google_account_id"], name: "index_apk_snapshots_on_google_account_id", using: :btree
  add_index "apk_snapshots", ["last_device"], name: "index_apk_snapshots_on_last_device", using: :btree
  add_index "apk_snapshots", ["last_scanned"], name: "index_apk_snapshots_on_last_scanned", using: :btree
  add_index "apk_snapshots", ["micro_proxy_id"], name: "index_apk_snapshots_on_micro_proxy_id", using: :btree
  add_index "apk_snapshots", ["scan_status"], name: "index_apk_snapshots_on_scan_status", using: :btree
  add_index "apk_snapshots", ["scan_version"], name: "index_apk_snapshots_on_scan_version", using: :btree
  add_index "apk_snapshots", ["status", "scan_status"], name: "index_apk_snapshots_on_status_and_scan_status", using: :btree
  add_index "apk_snapshots", ["try"], name: "index_apk_snapshots_on_try", using: :btree
  add_index "apk_snapshots", ["version_code"], name: "index_apk_snapshots_on_version_code", using: :btree

  create_table "apk_snapshots_sdk_dlls", force: :cascade do |t|
    t.integer  "apk_snapshot_id", limit: 4
    t.integer  "sdk_dll_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "apk_snapshots_sdk_dlls", ["apk_snapshot_id", "sdk_dll_id"], name: "index_apk_snapshot_id_sdk_dll_id", using: :btree
  add_index "apk_snapshots_sdk_dlls", ["sdk_dll_id"], name: "index_sdk_dll_id", using: :btree

  create_table "apk_snapshots_sdk_js_tags", force: :cascade do |t|
    t.integer  "apk_snapshot_id", limit: 4
    t.integer  "sdk_js_tag_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "apk_snapshots_sdk_js_tags", ["apk_snapshot_id", "sdk_js_tag_id"], name: "index_apk_snapshot_id_sdk_js_tag_id", using: :btree
  add_index "apk_snapshots_sdk_js_tags", ["sdk_js_tag_id"], name: "index_sdk_js_tag_id", using: :btree

  create_table "app_developers", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.boolean  "flagged",                default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "app_developers", ["name"], name: "index_app_developers_on_name", using: :btree

  create_table "app_developers_developers", force: :cascade do |t|
    t.integer  "app_developer_id", limit: 4
    t.integer  "developer_id",     limit: 4
    t.string   "developer_type",   limit: 191
    t.integer  "method",           limit: 4
    t.boolean  "flagged",                      default: false
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  add_index "app_developers_developers", ["app_developer_id"], name: "index_app_developers_developers_on_app_developer_id", using: :btree
  add_index "app_developers_developers", ["developer_id"], name: "index_app_developers_developers_on_developer_id", using: :btree
  add_index "app_developers_developers", ["developer_type", "developer_id"], name: "index_app_developers_on_developer_poly", unique: true, using: :btree

  create_table "app_store_scaling_factor_backups", force: :cascade do |t|
    t.integer  "app_store_id",                    limit: 4
    t.float    "ratings_all_count",               limit: 24
    t.float    "ratings_per_day_current_release", limit: 24
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "app_store_scaling_factor_backups", ["app_store_id"], name: "index_app_store_scaling_factor_backups_on_app_store_id", unique: true, using: :btree

  create_table "app_store_scaling_factors", force: :cascade do |t|
    t.integer  "app_store_id",                    limit: 4
    t.float    "ratings_all_count",               limit: 24
    t.float    "ratings_per_day_current_release", limit: 24
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  add_index "app_store_scaling_factors", ["app_store_id"], name: "index_app_store_scaling_factors_on_app_store_id", unique: true, using: :btree

  create_table "app_store_tos_snapshots", force: :cascade do |t|
    t.integer  "app_store_id",      limit: 4
    t.date     "last_updated_date"
    t.datetime "good_as_of_date"
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "app_store_tos_snapshots", ["app_store_id", "last_updated_date"], name: "index_app_store_tos_store_id_updated_date", using: :btree
  add_index "app_store_tos_snapshots", ["good_as_of_date"], name: "index_app_store_tos_snapshots_on_good_as_of_date", using: :btree
  add_index "app_store_tos_snapshots", ["last_updated_date"], name: "index_app_store_tos_snapshots_on_last_updated_date", using: :btree

  create_table "app_stores", force: :cascade do |t|
    t.string   "country_code",     limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",             limit: 191
    t.boolean  "enabled",                        default: false
    t.integer  "priority",         limit: 4
    t.integer  "display_priority", limit: 4
    t.boolean  "tos_valid",                      default: true
    t.text     "tos_url_path",     limit: 65535
  end

  add_index "app_stores", ["country_code"], name: "index_app_stores_on_country_code", using: :btree
  add_index "app_stores", ["display_priority"], name: "index_app_stores_on_display_priority", using: :btree
  add_index "app_stores", ["enabled"], name: "index_app_stores_on_enabled", using: :btree
  add_index "app_stores", ["name"], name: "index_app_stores_on_name", using: :btree
  add_index "app_stores", ["priority", "enabled"], name: "index_app_stores_on_priority_and_enabled", using: :btree
  add_index "app_stores", ["priority"], name: "index_app_stores_on_priority", unique: true, using: :btree
  add_index "app_stores", ["tos_valid"], name: "index_app_stores_on_tos_valid", using: :btree

  create_table "app_stores_ios_app_backups", force: :cascade do |t|
    t.integer  "ios_app_id",   limit: 4
    t.integer  "app_store_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "app_stores_ios_app_backups", ["app_store_id"], name: "index_app_stores_ios_app_backups_on_app_store_id", using: :btree
  add_index "app_stores_ios_app_backups", ["ios_app_id", "app_store_id"], name: "index_app_stores_ios_app_backups_on_ios_app_id_and_app_store_id", unique: true, using: :btree

  create_table "app_stores_ios_apps", force: :cascade do |t|
    t.integer  "app_store_id", limit: 4
    t.integer  "ios_app_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "app_stores_ios_apps", ["app_store_id"], name: "index_app_stores_ios_apps_on_app_store_id", using: :btree
  add_index "app_stores_ios_apps", ["ios_app_id", "app_store_id"], name: "index_app_stores_ios_apps_on_ios_app_id_and_app_store_id", unique: true, using: :btree

  create_table "apple_accounts", force: :cascade do |t|
    t.string   "email",         limit: 191
    t.string   "password",      limit: 191
    t.integer  "ios_device_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "app_store_id",  limit: 4
    t.integer  "kind",          limit: 4
    t.integer  "in_use",        limit: 4
    t.datetime "last_used"
  end

  add_index "apple_accounts", ["app_store_id"], name: "index_apple_accounts_on_app_store_id", using: :btree
  add_index "apple_accounts", ["email"], name: "index_apple_accounts_on_email", using: :btree
  add_index "apple_accounts", ["in_use"], name: "index_apple_accounts_on_in_use", using: :btree
  add_index "apple_accounts", ["ios_device_id"], name: "index_apple_accounts_on_ios_device_id", using: :btree
  add_index "apple_accounts", ["kind", "in_use"], name: "index_apple_accounts_on_kind_and_in_use", using: :btree
  add_index "apple_accounts", ["last_used", "kind", "in_use"], name: "index_apple_accounts_on_last_used_and_kind_and_in_use", using: :btree

  create_table "apple_docs", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "apple_docs", ["name"], name: "index_apple_docs_on_name", using: :btree

  create_table "apps", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id", limit: 4
    t.string   "name",       limit: 191
  end

  create_table "class_dumps", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "class_dump_file_name",     limit: 191
    t.string   "class_dump_content_type",  limit: 191
    t.integer  "class_dump_file_size",     limit: 4
    t.datetime "class_dump_updated_at"
    t.integer  "ipa_snapshot_id",          limit: 4
    t.boolean  "success"
    t.boolean  "install_success"
    t.boolean  "dump_success"
    t.boolean  "teardown_success"
    t.boolean  "teardown_retry"
    t.float    "duration",                 limit: 24
    t.float    "install_time",             limit: 24
    t.float    "dump_time",                limit: 24
    t.float    "teardown_time",            limit: 24
    t.text     "error",                    limit: 65535
    t.text     "trace",                    limit: 65535
    t.text     "error_root",               limit: 65535
    t.text     "error_teardown",           limit: 65535
    t.text     "error_teardown_trace",     limit: 65535
    t.string   "method",                   limit: 191
    t.boolean  "complete"
    t.integer  "error_code",               limit: 4
    t.integer  "ios_device_id",            limit: 4
    t.boolean  "has_fw_folder"
    t.integer  "apple_account_id",         limit: 4
    t.string   "app_content_file_name",    limit: 191
    t.string   "app_content_content_type", limit: 191
    t.integer  "app_content_file_size",    limit: 4
    t.datetime "app_content_updated_at"
    t.integer  "account_success",          limit: 4
  end

  add_index "class_dumps", ["account_success"], name: "index_class_dumps_on_account_success", using: :btree
  add_index "class_dumps", ["apple_account_id"], name: "index_class_dumps_on_apple_account_id", using: :btree
  add_index "class_dumps", ["complete"], name: "index_class_dumps_on_complete", using: :btree
  add_index "class_dumps", ["dump_success"], name: "index_class_dumps_on_dump_success", using: :btree
  add_index "class_dumps", ["dump_time"], name: "index_class_dumps_on_dump_time", using: :btree
  add_index "class_dumps", ["duration"], name: "index_class_dumps_on_duration", using: :btree
  add_index "class_dumps", ["error_code"], name: "index_class_dumps_on_error_code", using: :btree
  add_index "class_dumps", ["has_fw_folder"], name: "index_class_dumps_on_has_fw_folder", using: :btree
  add_index "class_dumps", ["install_success"], name: "index_class_dumps_on_install_success", using: :btree
  add_index "class_dumps", ["install_time"], name: "index_class_dumps_on_install_time", using: :btree
  add_index "class_dumps", ["ios_device_id"], name: "index_class_dumps_on_ios_device_id", using: :btree
  add_index "class_dumps", ["ipa_snapshot_id"], name: "index_class_dumps_on_ipa_snapshot_id", using: :btree
  add_index "class_dumps", ["method"], name: "index_class_dumps_on_method", using: :btree
  add_index "class_dumps", ["success"], name: "index_class_dumps_on_success", using: :btree
  add_index "class_dumps", ["teardown_retry"], name: "index_class_dumps_on_teardown_retry", using: :btree
  add_index "class_dumps", ["teardown_success"], name: "index_class_dumps_on_teardown_success", using: :btree
  add_index "class_dumps", ["teardown_time"], name: "index_class_dumps_on_teardown_time", using: :btree

  create_table "clearbit_contacts", force: :cascade do |t|
    t.integer  "website_id",      limit: 4
    t.string   "clearbit_id",     limit: 191
    t.string   "given_name",      limit: 191
    t.string   "family_name",     limit: 191
    t.string   "full_name",       limit: 191
    t.string   "title",           limit: 191
    t.string   "email",           limit: 191
    t.string   "linkedin",        limit: 191
    t.date     "updated"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "domain_datum_id", limit: 4
  end

  add_index "clearbit_contacts", ["clearbit_id"], name: "index_clearbit_contacts_on_clearbit_id", using: :btree
  add_index "clearbit_contacts", ["domain_datum_id"], name: "index_clearbit_contacts_on_domain_datum_id", using: :btree
  add_index "clearbit_contacts", ["updated_at"], name: "index_clearbit_contacts_on_updated_at", using: :btree
  add_index "clearbit_contacts", ["website_id"], name: "index_clearbit_contacts_on_website_id", using: :btree

  create_table "cocoapod_authors", force: :cascade do |t|
    t.string   "name",        limit: 191
    t.text     "email",       limit: 65535
    t.integer  "cocoapod_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cocoapod_authors", ["cocoapod_id"], name: "index_cocoapod_authors_on_cocoapod_id", using: :btree
  add_index "cocoapod_authors", ["name"], name: "index_cocoapod_authors_on_name", using: :btree

  create_table "cocoapod_exceptions", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "cocoapod_id", limit: 4
    t.text     "error",       limit: 65535
    t.text     "backtrace",   limit: 65535
  end

  add_index "cocoapod_exceptions", ["cocoapod_id"], name: "index_cocoapod_exceptions_on_cocoapod_id", using: :btree

  create_table "cocoapod_metric_exceptions", force: :cascade do |t|
    t.integer  "cocoapod_metric_id", limit: 4
    t.text     "error",              limit: 65535
    t.text     "backtrace",          limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cocoapod_metric_exceptions", ["cocoapod_metric_id"], name: "index_cocoapod_metric_exceptions_on_cocoapod_metric_id", using: :btree

  create_table "cocoapod_metrics", force: :cascade do |t|
    t.integer  "ios_sdk_id",                        limit: 4
    t.boolean  "success"
    t.integer  "stats_download_total",              limit: 4
    t.integer  "stats_download_week",               limit: 4
    t.integer  "stats_download_month",              limit: 4
    t.integer  "stats_app_total",                   limit: 4
    t.integer  "stats_app_week",                    limit: 4
    t.integer  "stats_tests_total",                 limit: 4
    t.integer  "stats_tests_week",                  limit: 4
    t.datetime "stats_created_at"
    t.datetime "stats_updated_at"
    t.integer  "stats_extension_week",              limit: 4
    t.integer  "stats_extension_total",             limit: 4
    t.integer  "stats_watch_week",                  limit: 4
    t.integer  "stats_watch_total",                 limit: 4
    t.integer  "stats_pod_try_week",                limit: 4
    t.integer  "stats_pod_try_total",               limit: 4
    t.boolean  "stats_is_active"
    t.integer  "github_subscribers",                limit: 4
    t.integer  "github_stargazers",                 limit: 4
    t.integer  "github_forks",                      limit: 4
    t.integer  "github_contributors",               limit: 4
    t.integer  "github_open_issues",                limit: 4
    t.integer  "github_open_pull_requests",         limit: 4
    t.datetime "github_created_at"
    t.datetime "github_updated_at"
    t.string   "github_language",                   limit: 191
    t.integer  "github_closed_issues",              limit: 4
    t.integer  "github_closed_pull_requests",       limit: 4
    t.integer  "cocoadocs_install_size",            limit: 4
    t.integer  "cocoadocs_total_files",             limit: 4
    t.integer  "cocoadocs_total_comments",          limit: 4
    t.integer  "cocoadocs_total_lines_of_code",     limit: 4
    t.integer  "cocoadocs_doc_percent",             limit: 4
    t.integer  "cocoadocs_readme_complexity",       limit: 4
    t.datetime "cocoadocs_initial_commit_date"
    t.string   "cocoadocs_rendered_readme_url",     limit: 191
    t.datetime "cocoadocs_created_at"
    t.datetime "cocoadocs_updated_at"
    t.string   "cocoadocs_license_short_name",      limit: 191
    t.string   "cocoadocs_license_canonical_url",   limit: 191
    t.integer  "cocoadocs_total_test_expectations", limit: 4
    t.string   "cocoadocs_dominant_language",       limit: 191
    t.integer  "cocoadocs_quality_estimate",        limit: 4
    t.boolean  "cocoadocs_builds_independently"
    t.boolean  "cocoadocs_is_vendored_framework"
    t.string   "cocoadocs_rendered_changelog_url",  limit: 191
    t.text     "cocoadocs_rendered_summary",        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cocoapod_metrics", ["ios_sdk_id"], name: "index_cocoapod_metrics_on_ios_sdk_id", using: :btree
  add_index "cocoapod_metrics", ["stats_app_total"], name: "index_cocoapod_metrics_on_stats_app_total", using: :btree
  add_index "cocoapod_metrics", ["stats_download_total"], name: "index_cocoapod_metrics_on_stats_download_total", using: :btree
  add_index "cocoapod_metrics", ["success"], name: "index_cocoapod_metrics_on_success", using: :btree

  create_table "cocoapod_source_data", force: :cascade do |t|
    t.string   "name",        limit: 191
    t.integer  "cocoapod_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "flagged",                 default: false
  end

  add_index "cocoapod_source_data", ["cocoapod_id"], name: "index_cocoapod_source_data_on_cocoapod_id", using: :btree
  add_index "cocoapod_source_data", ["flagged"], name: "index_cocoapod_source_data_on_flagged", using: :btree
  add_index "cocoapod_source_data", ["name", "flagged"], name: "index_cocoapod_source_data_on_name_and_flagged", using: :btree

  create_table "cocoapod_tags", force: :cascade do |t|
    t.string   "tag",         limit: 191
    t.integer  "cocoapod_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cocoapod_tags", ["cocoapod_id"], name: "index_cocoapod_tags_on_cocoapod_id", using: :btree
  add_index "cocoapod_tags", ["tag"], name: "index_cocoapod_tags_on_tag", using: :btree

  create_table "cocoapods", force: :cascade do |t|
    t.string   "version",      limit: 191
    t.text     "git",          limit: 65535
    t.text     "http",         limit: 65535
    t.string   "tag",          limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ios_sdk_id",   limit: 4
    t.text     "json_content", limit: 65535
  end

  add_index "cocoapods", ["ios_sdk_id", "version"], name: "index_cocoapods_on_ios_sdk_id_and_version", unique: true, using: :btree

  create_table "companies", force: :cascade do |t|
    t.string   "name",                   limit: 191
    t.string   "website",                limit: 191
    t.integer  "status",                 limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "fortune_1000_rank",      limit: 4
    t.string   "ceo_name",               limit: 191
    t.string   "street_address",         limit: 191
    t.string   "city",                   limit: 191
    t.string   "zip_code",               limit: 191
    t.string   "state",                  limit: 191
    t.integer  "employee_count",         limit: 4
    t.string   "industry",               limit: 191
    t.string   "type",                   limit: 191
    t.integer  "funding",                limit: 4
    t.integer  "inc_5000_rank",          limit: 4
    t.string   "country",                limit: 191
    t.integer  "app_store_identifier",   limit: 4
    t.string   "google_play_identifier", limit: 191
  end

  add_index "companies", ["app_store_identifier"], name: "index_app_store_identifier", using: :btree
  add_index "companies", ["fortune_1000_rank"], name: "index_companies_on_fortune_1000_rank", using: :btree
  add_index "companies", ["google_play_identifier"], name: "index_google_play_identifier", using: :btree
  add_index "companies", ["status"], name: "index_companies_on_status", using: :btree
  add_index "companies", ["website"], name: "index_companies_on_website", unique: true, using: :btree

  create_table "developer_link_options", force: :cascade do |t|
    t.integer  "ios_developer_id",     limit: 4
    t.integer  "android_developer_id", limit: 4
    t.integer  "method",               limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
  end

  add_index "developer_link_options", ["android_developer_id", "method"], name: "index_developer_link_options_on_android_developer_id_and_method", using: :btree
  add_index "developer_link_options", ["ios_developer_id", "method"], name: "index_developer_link_options_on_ios_developer_id_and_method", using: :btree
  add_index "developer_link_options", ["method"], name: "index_developer_link_options_on_method", using: :btree

  create_table "dll_regexes", force: :cascade do |t|
    t.string   "regex",          limit: 191
    t.integer  "android_sdk_id", limit: 4
    t.integer  "ios_sdk_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "domain_data", force: :cascade do |t|
    t.string   "clearbit_id",       limit: 191
    t.string   "name",              limit: 191
    t.string   "legal_name",        limit: 191
    t.string   "domain",            limit: 191
    t.text     "description",       limit: 65535
    t.string   "company_type",      limit: 191
    t.text     "tags",              limit: 65535
    t.string   "sector",            limit: 191
    t.string   "industry_group",    limit: 191
    t.string   "industry",          limit: 191
    t.string   "sub_industry",      limit: 191
    t.text     "tech_used",         limit: 65535
    t.integer  "founded_year",      limit: 4
    t.string   "time_zone",         limit: 191
    t.integer  "utc_offset",        limit: 4
    t.string   "street_number",     limit: 191
    t.string   "street_name",       limit: 191
    t.string   "sub_premise",       limit: 191
    t.string   "city",              limit: 191
    t.string   "postal_code",       limit: 191
    t.string   "state",             limit: 191
    t.string   "state_code",        limit: 191
    t.string   "country",           limit: 191
    t.string   "country_code",      limit: 191
    t.decimal  "lat",                             precision: 10, scale: 6
    t.decimal  "lng",                             precision: 10, scale: 6
    t.string   "logo_url",          limit: 191
    t.string   "facebook_handle",   limit: 191
    t.string   "linkedin_handle",   limit: 191
    t.string   "twitter_handle",    limit: 191
    t.string   "twitter_id",        limit: 191
    t.string   "crunchbase_handle", limit: 191
    t.boolean  "email_provider"
    t.string   "ticker",            limit: 191
    t.string   "phone",             limit: 191
    t.integer  "alexa_us_rank",     limit: 4
    t.integer  "alexa_global_rank", limit: 4
    t.integer  "google_rank",       limit: 4
    t.integer  "employees",         limit: 4
    t.string   "employees_range",   limit: 191
    t.integer  "market_cap",        limit: 8
    t.integer  "raised",            limit: 8
    t.integer  "annual_revenue",    limit: 8
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
  end

  add_index "domain_data", ["annual_revenue"], name: "index_domain_data_on_annual_revenue", using: :btree
  add_index "domain_data", ["country_code"], name: "index_domain_data_on_country_code", using: :btree
  add_index "domain_data", ["domain"], name: "index_domain_data_on_domain", unique: true, using: :btree
  add_index "domain_data", ["employees"], name: "index_domain_data_on_employees", using: :btree
  add_index "domain_data", ["market_cap"], name: "index_domain_data_on_market_cap", using: :btree
  add_index "domain_data", ["raised"], name: "index_domain_data_on_raised", using: :btree
  add_index "domain_data", ["state_code", "country_code"], name: "index_domain_data_on_state_code_and_country_code", using: :btree

  create_table "dummy_models", force: :cascade do |t|
    t.string   "dummy",             limit: 191
    t.text     "dummy_text",        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "is_it_medium_text", limit: 65535
  end

  create_table "dupes", force: :cascade do |t|
    t.string   "app_identifier", limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "count",          limit: 4
  end

  add_index "dupes", ["app_identifier"], name: "index_dupes_on_app_identifier", using: :btree
  add_index "dupes", ["count"], name: "index_dupes_on_count", using: :btree

  create_table "epf_application_device_types", force: :cascade do |t|
    t.integer  "export_date",    limit: 8
    t.integer  "application_id", limit: 4
    t.integer  "device_type_id", limit: 4
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "epf_application_device_types", ["application_id", "device_type_id"], name: "index_epf_app_device_type", unique: true, using: :btree
  add_index "epf_application_device_types", ["device_type_id"], name: "index_epf_application_device_types_on_device_type_id", using: :btree

  create_table "epf_applications", force: :cascade do |t|
    t.integer  "export_date",         limit: 8
    t.integer  "application_id",      limit: 4
    t.text     "title",               limit: 65535
    t.text     "recommended_age",     limit: 65535
    t.text     "artist_name",         limit: 65535
    t.text     "seller_name",         limit: 65535
    t.text     "company_url",         limit: 65535
    t.text     "support_url",         limit: 65535
    t.text     "view_url",            limit: 65535
    t.text     "artwork_url_large",   limit: 65535
    t.text     "artwork_url_small",   limit: 65535
    t.datetime "itunes_release_date"
    t.text     "copyright",           limit: 65535
    t.text     "description",         limit: 65535
    t.text     "version",             limit: 65535
    t.text     "itunes_version",      limit: 65535
    t.integer  "download_size",       limit: 8
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "epf_applications", ["application_id"], name: "index_epf_applications_on_application_id", unique: true, using: :btree

  create_table "epf_device_types", force: :cascade do |t|
    t.integer  "export_date",    limit: 8
    t.integer  "device_type_id", limit: 4,     null: false
    t.text     "name",           limit: 65535
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
  end

  add_index "epf_device_types", ["device_type_id"], name: "index_epf_device_types_on_device_type_id", unique: true, using: :btree

  create_table "epf_full_feeds", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "epf_full_feeds", ["name"], name: "index_epf_full_feeds_on_name", using: :btree

  create_table "epf_storefronts", force: :cascade do |t|
    t.integer  "export_date",   limit: 8
    t.integer  "storefront_id", limit: 4
    t.string   "country_code",  limit: 191
    t.text     "name",          limit: 65535
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  add_index "epf_storefronts", ["country_code"], name: "index_epf_storefronts_on_country_code", unique: true, using: :btree
  add_index "epf_storefronts", ["storefront_id"], name: "index_epf_storefronts_on_storefront_id", unique: true, using: :btree

  create_table "fb_accounts", force: :cascade do |t|
    t.string   "username",     limit: 191
    t.string   "password",     limit: 191
    t.datetime "last_browsed"
    t.datetime "last_scraped"
    t.boolean  "flagged",                  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "browsable",                default: false
  end

  create_table "fb_accounts_ios_devices", force: :cascade do |t|
    t.integer  "fb_account_id", limit: 4
    t.integer  "ios_device_id", limit: 4
    t.boolean  "flagged",                 default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fb_accounts_ios_devices", ["fb_account_id", "ios_device_id"], name: "index_fb_account_id_ios_device_id", using: :btree
  add_index "fb_accounts_ios_devices", ["ios_device_id"], name: "index_fb_accounts_ios_devices_on_ios_device_id", using: :btree

  create_table "fb_activities", force: :cascade do |t|
    t.integer  "fb_activity_job_id", limit: 4
    t.integer  "fb_account_id",      limit: 4
    t.integer  "likes",              limit: 4
    t.text     "status",             limit: 65535
    t.float    "duration",           limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fb_activities", ["fb_account_id"], name: "index_fb_activities_on_fb_account_id", using: :btree
  add_index "fb_activities", ["fb_activity_job_id"], name: "index_fb_activities_on_fb_activity_job_id", using: :btree

  create_table "fb_activity_exceptions", force: :cascade do |t|
    t.integer  "fb_account_id",      limit: 4
    t.text     "error",              limit: 65535
    t.text     "backtrace",          limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "fb_activity_job_id", limit: 4
  end

  add_index "fb_activity_exceptions", ["fb_account_id"], name: "index_fb_activity_exceptions_on_fb_account_id", using: :btree
  add_index "fb_activity_exceptions", ["fb_activity_job_id"], name: "index_fb_activity_exceptions_on_fb_activity_job_id", using: :btree

  create_table "fb_activity_jobs", force: :cascade do |t|
    t.text     "notes",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "fb_statuses", force: :cascade do |t|
    t.text     "status",     limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "follow_relationships", force: :cascade do |t|
    t.integer  "followable_id",   limit: 4,   null: false
    t.string   "followable_type", limit: 191, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "follower_id",     limit: 4
    t.string   "follower_type",   limit: 191
  end

  add_index "follow_relationships", ["followable_type", "followable_id"], name: "index_follow_relationships_on_followable_type_and_followable_id", using: :btree
  add_index "follow_relationships", ["follower_type", "follower_id"], name: "index_follow_relationships_on_follower_type_and_follower_id", using: :btree

  create_table "github_accounts", force: :cascade do |t|
    t.string   "username",         limit: 191
    t.string   "email",            limit: 191
    t.string   "password",         limit: 191
    t.string   "application_name", limit: 191
    t.string   "homepage_url",     limit: 191
    t.string   "callback_url",     limit: 191
    t.string   "client_id",        limit: 191
    t.string   "client_secret",    limit: 191
    t.datetime "last_used"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "github_accounts", ["last_used"], name: "index_github_accounts_on_last_used", using: :btree

  create_table "google_accounts", force: :cascade do |t|
    t.string   "email",              limit: 191
    t.string   "password",           limit: 191
    t.string   "android_identifier", limit: 191
    t.integer  "proxy_id",           limit: 4
    t.boolean  "blocked"
    t.integer  "flags",              limit: 4
    t.datetime "last_used"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "in_use"
    t.integer  "device",             limit: 4
    t.integer  "scrape_type",        limit: 4,   default: 0
    t.string   "auth_token",         limit: 191
  end

  add_index "google_accounts", ["blocked"], name: "index_google_accounts_on_blocked", using: :btree
  add_index "google_accounts", ["device"], name: "index_google_accounts_on_device", using: :btree
  add_index "google_accounts", ["flags"], name: "index_google_accounts_on_flags", using: :btree
  add_index "google_accounts", ["last_used"], name: "index_google_accounts_on_last_used", using: :btree
  add_index "google_accounts", ["proxy_id"], name: "index_google_accounts_on_proxy_id", using: :btree
  add_index "google_accounts", ["scrape_type"], name: "index_google_accounts_on_scrape_type", using: :btree

  create_table "header_regexes", force: :cascade do |t|
    t.text     "regex",      limit: 65535
    t.integer  "ios_sdk_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "header_regexes", ["ios_sdk_id"], name: "index_header_regexes_on_ios_sdk_id", using: :btree

  create_table "installations", force: :cascade do |t|
    t.integer  "company_id",        limit: 4
    t.integer  "service_id",        limit: 4
    t.integer  "scraped_result_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",            limit: 4
    t.integer  "scrape_job_id",     limit: 4
  end

  add_index "installations", ["company_id", "created_at"], name: "index_installations_on_company_id_and_created_at", using: :btree
  add_index "installations", ["scrape_job_id"], name: "index_installations_on_scrape_job_id", using: :btree
  add_index "installations", ["scraped_result_id"], name: "index_installations_on_scraped_result_id", using: :btree
  add_index "installations", ["service_id", "created_at"], name: "index_installations_on_service_id_and_created_at", using: :btree
  add_index "installations", ["status", "created_at"], name: "index_installations_on_status_and_created_at", using: :btree

  create_table "ios_app_categories", force: :cascade do |t|
    t.string   "name",                limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "category_identifier", limit: 4
  end

  add_index "ios_app_categories", ["category_identifier"], name: "index_ios_app_categories_on_category_identifier", unique: true, using: :btree
  add_index "ios_app_categories", ["name"], name: "index_ios_app_categories_on_name", using: :btree

  create_table "ios_app_categories_current_snapshot_backups", force: :cascade do |t|
    t.integer  "ios_app_category_id",         limit: 4
    t.integer  "ios_app_current_snapshot_id", limit: 4
    t.integer  "kind",                        limit: 4
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "ios_app_categories_current_snapshot_backups", ["ios_app_category_id"], name: "index_backup_ios_category_snapshot_on_category_id", using: :btree
  add_index "ios_app_categories_current_snapshot_backups", ["ios_app_current_snapshot_id", "ios_app_category_id", "kind"], name: "index_backup_ios_category_snap_on_snap_id_cat_id_kind", unique: true, using: :btree
  add_index "ios_app_categories_current_snapshot_backups", ["kind"], name: "index_ios_app_categories_current_snapshot_backups_on_kind", using: :btree

  create_table "ios_app_categories_current_snapshots", force: :cascade do |t|
    t.integer  "ios_app_category_id",         limit: 4
    t.integer  "ios_app_current_snapshot_id", limit: 4
    t.integer  "kind",                        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_app_categories_current_snapshots", ["ios_app_category_id"], name: "index_on_ios_app_category_id", using: :btree
  add_index "ios_app_categories_current_snapshots", ["ios_app_current_snapshot_id", "ios_app_category_id", "kind"], name: "index_on_ios_app_snapshot_ios_app_category_id_kind", unique: true, using: :btree
  add_index "ios_app_categories_current_snapshots", ["kind"], name: "index_ios_app_categories_current_snapshots_on_kind", using: :btree

  create_table "ios_app_categories_snapshots", force: :cascade do |t|
    t.integer  "ios_app_category_id", limit: 4
    t.integer  "ios_app_snapshot_id", limit: 4
    t.integer  "kind",                limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_app_categories_snapshots", ["ios_app_category_id"], name: "index_ios_app_categories_snapshots_on_ios_app_category_id", using: :btree
  add_index "ios_app_categories_snapshots", ["ios_app_snapshot_id", "ios_app_category_id", "kind"], name: "index_ios_app_snapshot_id_category_id_kind", using: :btree
  add_index "ios_app_categories_snapshots", ["kind"], name: "index_ios_app_categories_snapshots_on_kind", using: :btree

  create_table "ios_app_category_name_backups", force: :cascade do |t|
    t.string   "name",                limit: 191
    t.integer  "app_store_id",        limit: 4
    t.integer  "ios_app_category_id", limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "ios_app_category_name_backups", ["app_store_id"], name: "index_ios_app_category_name_backups_on_app_store_id", using: :btree
  add_index "ios_app_category_name_backups", ["ios_app_category_id", "app_store_id"], name: "index_backup_on_ios_app_category_id_and_app_store_id", unique: true, using: :btree
  add_index "ios_app_category_name_backups", ["name"], name: "index_ios_app_category_name_backups_on_name", using: :btree

  create_table "ios_app_category_names", force: :cascade do |t|
    t.string   "name",                limit: 191
    t.integer  "app_store_id",        limit: 4
    t.integer  "ios_app_category_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_app_category_names", ["app_store_id"], name: "index_ios_app_category_names_on_app_store_id", using: :btree
  add_index "ios_app_category_names", ["ios_app_category_id", "app_store_id"], name: "index_on_ios_app_category_id_and_app_store_id", unique: true, using: :btree
  add_index "ios_app_category_names", ["name"], name: "index_ios_app_category_names_on_name", using: :btree

  create_table "ios_app_current_snapshot_backups", force: :cascade do |t|
    t.string   "name",                            limit: 191
    t.integer  "price",                           limit: 4
    t.integer  "size",                            limit: 8
    t.string   "seller_url",                      limit: 191
    t.string   "version",                         limit: 191
    t.date     "released"
    t.string   "recommended_age",                 limit: 191
    t.text     "description",                     limit: 65535
    t.integer  "ios_app_id",                      limit: 4
    t.string   "required_ios_version",            limit: 191
    t.integer  "ios_app_current_snapshot_job_id", limit: 4
    t.text     "release_notes",                   limit: 65535
    t.integer  "developer_app_store_identifier",  limit: 4
    t.decimal  "ratings_current_stars",                         precision: 10
    t.integer  "ratings_current_count",           limit: 4
    t.decimal  "ratings_all_stars",                             precision: 10
    t.integer  "ratings_all_count",               limit: 4
    t.text     "icon_url_60x60",                  limit: 65535
    t.text     "icon_url_100x100",                limit: 65535
    t.text     "icon_url_512x512",                limit: 65535
    t.decimal  "ratings_per_day_current_release",               precision: 10
    t.date     "first_released"
    t.boolean  "game_center_enabled"
    t.string   "bundle_identifier",               limit: 191
    t.string   "currency",                        limit: 191
    t.text     "screenshot_urls",                 limit: 65535
    t.integer  "app_store_id",                    limit: 4
    t.integer  "app_identifier",                  limit: 4
    t.integer  "mobile_priority",                 limit: 4
    t.integer  "user_base",                       limit: 4
    t.datetime "created_at",                                                   null: false
    t.datetime "updated_at",                                                   null: false
    t.text     "app_link_urls",                   limit: 65535
    t.boolean  "has_in_app_purchases"
    t.text     "seller_name",                     limit: 65535
  end

  add_index "ios_app_current_snapshot_backups", ["app_identifier"], name: "index_ios_app_current_snapshot_backups_on_app_identifier", using: :btree
  add_index "ios_app_current_snapshot_backups", ["app_store_id", "ratings_all_count"], name: "index_backup_app_current_store_id_ratings_count", using: :btree
  add_index "ios_app_current_snapshot_backups", ["app_store_id", "ratings_per_day_current_release"], name: "index_backup_ios_app_current_store_id_rpd", using: :btree
  add_index "ios_app_current_snapshot_backups", ["developer_app_store_identifier"], name: "index_current_snapshot_backups_developer_id", using: :btree
  add_index "ios_app_current_snapshot_backups", ["ios_app_current_snapshot_job_id"], name: "index_ios_app_backup_on_job_id", using: :btree
  add_index "ios_app_current_snapshot_backups", ["ios_app_id", "app_store_id"], name: "index_backup_ios_app_current_snap_app_id_store_id", unique: true, using: :btree
  add_index "ios_app_current_snapshot_backups", ["mobile_priority"], name: "index_ios_app_current_snapshot_backups_on_mobile_priority", using: :btree
  add_index "ios_app_current_snapshot_backups", ["ratings_all_count"], name: "index_backup_ios_app_current_ratings_count", using: :btree
  add_index "ios_app_current_snapshot_backups", ["ratings_per_day_current_release"], name: "index_backup_ios_app_current_rpd", using: :btree
  add_index "ios_app_current_snapshot_backups", ["user_base"], name: "index_ios_app_current_snapshot_backups_on_user_base", using: :btree

  create_table "ios_app_current_snapshot_jobs", force: :cascade do |t|
    t.text     "notes",      limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "ios_app_current_snapshots", force: :cascade do |t|
    t.string   "name",                            limit: 191
    t.integer  "price",                           limit: 4
    t.integer  "size",                            limit: 8
    t.string   "seller_url",                      limit: 191
    t.string   "version",                         limit: 191
    t.date     "released"
    t.string   "recommended_age",                 limit: 191
    t.text     "description",                     limit: 65535
    t.integer  "ios_app_id",                      limit: 4
    t.string   "required_ios_version",            limit: 191
    t.integer  "ios_app_current_snapshot_job_id", limit: 4
    t.text     "release_notes",                   limit: 65535
    t.integer  "developer_app_store_identifier",  limit: 4
    t.decimal  "ratings_current_stars",                         precision: 3,  scale: 2
    t.integer  "ratings_current_count",           limit: 4
    t.decimal  "ratings_all_stars",                             precision: 3,  scale: 2
    t.integer  "ratings_all_count",               limit: 4
    t.text     "icon_url_60x60",                  limit: 65535
    t.text     "icon_url_100x100",                limit: 65535
    t.text     "icon_url_512x512",                limit: 65535
    t.decimal  "ratings_per_day_current_release",               precision: 10, scale: 2
    t.date     "first_released"
    t.boolean  "game_center_enabled"
    t.string   "bundle_identifier",               limit: 191
    t.string   "currency",                        limit: 191
    t.text     "screenshot_urls",                 limit: 65535
    t.integer  "app_store_id",                    limit: 4
    t.integer  "app_identifier",                  limit: 4
    t.integer  "mobile_priority",                 limit: 4
    t.integer  "user_base",                       limit: 4
    t.datetime "created_at",                                                             null: false
    t.datetime "updated_at",                                                             null: false
    t.text     "app_link_urls",                   limit: 65535
    t.boolean  "has_in_app_purchases"
    t.text     "seller_name",                     limit: 65535
  end

  add_index "ios_app_current_snapshots", ["app_identifier"], name: "index_ios_app_current_snapshots_on_app_identifier", using: :btree
  add_index "ios_app_current_snapshots", ["app_store_id", "ratings_all_count"], name: "index_app_current_store_id_ratings_count", using: :btree
  add_index "ios_app_current_snapshots", ["app_store_id", "ratings_per_day_current_release"], name: "index_ios_app_current_store_id_rpd", using: :btree
  add_index "ios_app_current_snapshots", ["developer_app_store_identifier"], name: "index_current_snapshots_developer_id", using: :btree
  add_index "ios_app_current_snapshots", ["ios_app_current_snapshot_job_id"], name: "index_on_ios_app_current_snapshot_job_id", using: :btree
  add_index "ios_app_current_snapshots", ["ios_app_id", "app_store_id"], name: "index_ios_app_current_snap_app_id_store_id", unique: true, using: :btree
  add_index "ios_app_current_snapshots", ["mobile_priority"], name: "index_ios_app_current_snapshots_on_mobile_priority", using: :btree
  add_index "ios_app_current_snapshots", ["ratings_all_count"], name: "index_ios_app_current_ratings_count", using: :btree
  add_index "ios_app_current_snapshots", ["ratings_per_day_current_release"], name: "index_ios_app_current_rpd", using: :btree
  add_index "ios_app_current_snapshots", ["user_base"], name: "index_ios_app_current_snapshots_on_user_base", using: :btree

  create_table "ios_app_download_snapshot_exceptions", force: :cascade do |t|
    t.integer  "ios_app_download_snapshot_id",     limit: 4
    t.text     "name",                             limit: 65535
    t.text     "backtrace",                        limit: 65535
    t.integer  "try",                              limit: 4
    t.integer  "ios_app_download_snapshot_job_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_app_download_snapshot_exceptions", ["ios_app_download_snapshot_id"], name: "index_on_ios_app_download_snapshot_id", using: :btree
  add_index "ios_app_download_snapshot_exceptions", ["ios_app_download_snapshot_job_id"], name: "index_on_ios_app_download_snapshot_job_id", using: :btree

  create_table "ios_app_download_snapshot_jobs", force: :cascade do |t|
    t.string   "notes",      limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ios_app_download_snapshots", force: :cascade do |t|
    t.integer  "downloads",                        limit: 8
    t.integer  "ios_app_id",                       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ios_app_download_snapshot_job_id", limit: 4
    t.integer  "status",                           limit: 4
  end

  add_index "ios_app_download_snapshots", ["ios_app_download_snapshot_job_id"], name: "index_on_ios_app_download_snapshot_job_id", using: :btree
  add_index "ios_app_download_snapshots", ["ios_app_id"], name: "index_ios_app_download_snapshots_on_ios_app_id", using: :btree
  add_index "ios_app_download_snapshots", ["status"], name: "index_ios_app_download_snapshots_on_status", using: :btree

  create_table "ios_app_epf_snapshots", force: :cascade do |t|
    t.integer  "export_date",         limit: 8
    t.integer  "application_id",      limit: 4
    t.text     "title",               limit: 65535
    t.string   "recommended_age",     limit: 191
    t.text     "artist_name",         limit: 65535
    t.string   "seller_name",         limit: 191
    t.text     "company_url",         limit: 65535
    t.text     "support_url",         limit: 65535
    t.text     "view_url",            limit: 65535
    t.text     "artwork_url_large",   limit: 65535
    t.string   "artwork_url_small",   limit: 191
    t.date     "itunes_release_date"
    t.text     "copyright",           limit: 65535
    t.text     "description",         limit: 65535
    t.string   "version",             limit: 191
    t.string   "itunes_version",      limit: 191
    t.integer  "download_size",       limit: 8
    t.integer  "epf_full_feed_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_app_epf_snapshots", ["application_id", "epf_full_feed_id"], name: "index_application_id_and_epf_full_feed_id", using: :btree
  add_index "ios_app_epf_snapshots", ["application_id"], name: "index_ios_app_epf_snapshots_on_application_id", using: :btree
  add_index "ios_app_epf_snapshots", ["artwork_url_small"], name: "index_ios_app_epf_snapshots_on_artwork_url_small", using: :btree
  add_index "ios_app_epf_snapshots", ["download_size"], name: "index_ios_app_epf_snapshots_on_download_size", using: :btree
  add_index "ios_app_epf_snapshots", ["epf_full_feed_id"], name: "index_ios_app_epf_snapshots_on_epf_full_feed_id", using: :btree
  add_index "ios_app_epf_snapshots", ["export_date"], name: "index_ios_app_epf_snapshots_on_export_date", using: :btree
  add_index "ios_app_epf_snapshots", ["itunes_release_date"], name: "index_ios_app_epf_snapshots_on_itunes_release_date", using: :btree
  add_index "ios_app_epf_snapshots", ["itunes_version"], name: "index_ios_app_epf_snapshots_on_itunes_version", using: :btree
  add_index "ios_app_epf_snapshots", ["recommended_age"], name: "index_ios_app_epf_snapshots_on_recommended_age", using: :btree
  add_index "ios_app_epf_snapshots", ["seller_name"], name: "index_ios_app_epf_snapshots_on_seller_name", using: :btree
  add_index "ios_app_epf_snapshots", ["version"], name: "index_ios_app_epf_snapshots_on_version", using: :btree

  create_table "ios_app_languages", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",       limit: 191
  end

  add_index "ios_app_languages", ["name"], name: "index_ios_app_languages_on_name", using: :btree

  create_table "ios_app_ranking_snapshots", force: :cascade do |t|
    t.integer  "kind",       limit: 4
    t.boolean  "is_valid",             default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_app_ranking_snapshots", ["is_valid"], name: "index_ios_app_ranking_snapshots_on_is_valid", using: :btree
  add_index "ios_app_ranking_snapshots", ["kind", "is_valid"], name: "index_ios_app_ranking_snapshots_on_kind_and_is_valid", using: :btree

  create_table "ios_app_rankings", force: :cascade do |t|
    t.integer  "ios_app_id",                  limit: 4
    t.integer  "ios_app_ranking_snapshot_id", limit: 4
    t.integer  "rank",                        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_app_rankings", ["ios_app_id", "rank"], name: "index_ios_app_rankings_on_ios_app_id_and_rank", using: :btree
  add_index "ios_app_rankings", ["ios_app_ranking_snapshot_id", "ios_app_id", "rank"], name: "index_on_ios_app_ranking_snapshot_id_and_ios_app_id_and_rank", using: :btree
  add_index "ios_app_rankings", ["rank"], name: "index_ios_app_rankings_on_rank", using: :btree

  create_table "ios_app_snapshot_exceptions", force: :cascade do |t|
    t.integer  "ios_app_snapshot_id",     limit: 4
    t.text     "name",                    limit: 65535
    t.text     "backtrace",               limit: 65535
    t.integer  "try",                     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ios_app_snapshot_job_id", limit: 4
  end

  add_index "ios_app_snapshot_exceptions", ["ios_app_snapshot_id"], name: "index_ios_app_snapshot_exceptions_on_ios_app_snapshot_id", using: :btree
  add_index "ios_app_snapshot_exceptions", ["ios_app_snapshot_job_id"], name: "index_ios_app_snapshot_job_id", using: :btree

  create_table "ios_app_snapshot_jobs", force: :cascade do |t|
    t.text     "notes",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ios_app_snapshots", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                            limit: 191
    t.integer  "price",                           limit: 4
    t.integer  "size",                            limit: 8
    t.string   "seller_url",                      limit: 191
    t.string   "support_url",                     limit: 191
    t.string   "version",                         limit: 191
    t.date     "released"
    t.string   "recommended_age",                 limit: 191
    t.text     "description",                     limit: 65535
    t.integer  "ios_app_id",                      limit: 4
    t.string   "required_ios_version",            limit: 191
    t.integer  "ios_app_snapshot_job_id",         limit: 4
    t.text     "release_notes",                   limit: 65535
    t.string   "seller",                          limit: 191
    t.integer  "developer_app_store_identifier",  limit: 4
    t.decimal  "ratings_current_stars",                         precision: 3,  scale: 2
    t.integer  "ratings_current_count",           limit: 4
    t.decimal  "ratings_all_stars",                             precision: 3,  scale: 2
    t.integer  "ratings_all_count",               limit: 4
    t.boolean  "editors_choice"
    t.integer  "status",                          limit: 4
    t.text     "exception_backtrace",             limit: 65535
    t.text     "exception",                       limit: 65535
    t.string   "icon_url_350x350",                limit: 191
    t.string   "icon_url_175x175",                limit: 191
    t.decimal  "ratings_per_day_current_release",               precision: 10, scale: 2
    t.date     "first_released"
    t.string   "by",                              limit: 191
    t.string   "copywright",                      limit: 191
    t.string   "seller_url_text",                 limit: 191
    t.string   "support_url_text",                limit: 191
  end

  add_index "ios_app_snapshots", ["developer_app_store_identifier"], name: "index_ios_app_snapshots_on_developer_app_store_identifier", using: :btree
  add_index "ios_app_snapshots", ["first_released"], name: "index_ios_app_snapshots_on_first_released", using: :btree
  add_index "ios_app_snapshots", ["ios_app_id", "name"], name: "index_ios_app_snapshots_on_ios_app_id_and_name", using: :btree
  add_index "ios_app_snapshots", ["ios_app_id", "released"], name: "index_ios_app_snapshots_on_ios_app_id_and_released", using: :btree
  add_index "ios_app_snapshots", ["ios_app_id"], name: "index_ios_app_snapshots_on_ios_app_id", using: :btree
  add_index "ios_app_snapshots", ["ios_app_snapshot_job_id"], name: "index_ios_app_snapshots_on_ios_app_snapshot_job_id", using: :btree
  add_index "ios_app_snapshots", ["name"], name: "index_ios_app_snapshots_on_name", using: :btree
  add_index "ios_app_snapshots", ["ratings_all_count"], name: "index_ios_app_snapshots_on_ratings_all_count", using: :btree
  add_index "ios_app_snapshots", ["released"], name: "index_ios_app_snapshots_on_released", using: :btree
  add_index "ios_app_snapshots", ["support_url"], name: "index_ios_app_snapshots_on_support_url", using: :btree

  create_table "ios_app_snapshots_languages", force: :cascade do |t|
    t.integer  "ios_app_snapshot_id", limit: 4
    t.integer  "ios_app_language_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_app_snapshots_languages", ["ios_app_language_id"], name: "index_ios_app_snapshots_languages_on_ios_app_language_id", using: :btree
  add_index "ios_app_snapshots_languages", ["ios_app_snapshot_id", "ios_app_language_id"], name: "index_ios_app_snapshot_id_language_id", using: :btree

  create_table "ios_app_snapshots_scr_shts", force: :cascade do |t|
    t.string   "url",                 limit: 191
    t.integer  "position",            limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "ios_app_snapshot_id", limit: 4
  end

  add_index "ios_app_snapshots_scr_shts", ["ios_app_snapshot_id"], name: "index_ios_app_snapshots_scr_shts_on_ios_app_snapshot_id", using: :btree

  create_table "ios_apps", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "app_identifier",             limit: 4
    t.integer  "app_id",                     limit: 4
    t.integer  "newest_ios_app_snapshot_id", limit: 4
    t.integer  "user_base",                  limit: 4
    t.integer  "mobile_priority",            limit: 4
    t.date     "released"
    t.integer  "newest_ipa_snapshot_id",     limit: 4
    t.integer  "display_type",               limit: 4, default: 0
    t.integer  "ios_developer_id",           limit: 4
    t.boolean  "app_store_available",                  default: true
    t.integer  "source",                     limit: 4
  end

  add_index "ios_apps", ["app_identifier"], name: "index_ios_apps_on_app_identifier", using: :btree
  add_index "ios_apps", ["app_store_available"], name: "index_ios_apps_on_app_store_available", using: :btree
  add_index "ios_apps", ["display_type"], name: "index_ios_apps_on_display_type", using: :btree
  add_index "ios_apps", ["ios_developer_id"], name: "index_ios_apps_on_ios_developer_id", using: :btree
  add_index "ios_apps", ["mobile_priority"], name: "index_ios_apps_on_mobile_priority", using: :btree
  add_index "ios_apps", ["newest_ios_app_snapshot_id"], name: "index_ios_apps_on_newest_ios_app_snapshot_id", using: :btree
  add_index "ios_apps", ["newest_ipa_snapshot_id"], name: "index_ios_apps_on_newest_ipa_snapshot_id", using: :btree
  add_index "ios_apps", ["released"], name: "index_ios_apps_on_released", using: :btree
  add_index "ios_apps", ["source"], name: "index_ios_apps_on_source", using: :btree
  add_index "ios_apps", ["user_base"], name: "index_ios_apps_on_user_base", using: :btree

  create_table "ios_apps_websites", force: :cascade do |t|
    t.integer  "ios_app_id", limit: 4
    t.integer  "website_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_apps_websites", ["ios_app_id"], name: "index_ios_apps_websites_on_ios_app_id", using: :btree
  add_index "ios_apps_websites", ["website_id", "ios_app_id"], name: "index_website_id_and_ios_app_id", using: :btree

  create_table "ios_classification_exceptions", force: :cascade do |t|
    t.integer  "ipa_snapshot_id", limit: 4
    t.text     "error",           limit: 65535
    t.text     "backtrace",       limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_classification_exceptions", ["ipa_snapshot_id"], name: "index_ios_classification_exceptions_on_ipa_snapshot_id", using: :btree

  create_table "ios_classification_headers", force: :cascade do |t|
    t.string   "name",              limit: 191
    t.integer  "ios_sdk_id",        limit: 4
    t.boolean  "is_unique"
    t.text     "collision_sdk_ids", limit: 65535
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "ios_classification_headers", ["ios_sdk_id", "is_unique"], name: "index_ios_header_sdk_id_unique", using: :btree
  add_index "ios_classification_headers", ["is_unique"], name: "index_ios_classification_headers_on_is_unique", using: :btree
  add_index "ios_classification_headers", ["name"], name: "index_ios_classification_headers_on_name", unique: true, using: :btree

  create_table "ios_classification_headers_backups", force: :cascade do |t|
    t.string   "name",              limit: 191
    t.integer  "ios_sdk_id",        limit: 4
    t.boolean  "is_unique"
    t.text     "collision_sdk_ids", limit: 65535
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  add_index "ios_classification_headers_backups", ["ios_sdk_id", "is_unique"], name: "index_ios_header_backup_sdk_id_unique", using: :btree
  add_index "ios_classification_headers_backups", ["is_unique"], name: "index_ios_classification_headers_backups_on_is_unique", using: :btree
  add_index "ios_classification_headers_backups", ["name"], name: "index_ios_classification_headers_backups_on_name", unique: true, using: :btree

  create_table "ios_developers", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.integer  "identifier", limit: 4
    t.integer  "company_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_developers", ["company_id"], name: "index_ios_developers_on_company_id", using: :btree
  add_index "ios_developers", ["identifier"], name: "index_ios_developers_on_identifier", unique: true, using: :btree
  add_index "ios_developers", ["name"], name: "index_ios_developers_on_name", using: :btree

  create_table "ios_developers_websites", force: :cascade do |t|
    t.integer  "ios_developer_id", limit: 4
    t.integer  "website_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_valid",                   default: true
  end

  add_index "ios_developers_websites", ["ios_developer_id", "is_valid"], name: "ios_developers_websites_is_valid", using: :btree
  add_index "ios_developers_websites", ["ios_developer_id", "website_id"], name: "index_ios_developers_websites_on_ios_developer_id_and_website_id", using: :btree
  add_index "ios_developers_websites", ["website_id"], name: "index_ios_developers_websites_on_website_id", using: :btree

  create_table "ios_device_arches", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "deprecated",             default: false
  end

  add_index "ios_device_arches", ["name"], name: "index_ios_device_arches_on_name", using: :btree

  create_table "ios_device_families", force: :cascade do |t|
    t.string   "name",               limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ios_device_arch_id", limit: 4
    t.string   "lookup_name",        limit: 191
    t.boolean  "active",                         default: true
  end

  add_index "ios_device_families", ["active"], name: "index_ios_device_families_on_active", using: :btree
  add_index "ios_device_families", ["ios_device_arch_id"], name: "index_ios_device_families_on_ios_device_arch_id", using: :btree
  add_index "ios_device_families", ["lookup_name"], name: "index_ios_device_families_on_lookup_name", using: :btree

  create_table "ios_device_models", force: :cascade do |t|
    t.integer  "ios_device_family_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                 limit: 191
  end

  add_index "ios_device_models", ["ios_device_family_id"], name: "index_ios_device_models_on_ios_device_family_id", using: :btree
  add_index "ios_device_models", ["name"], name: "index_ios_device_models_on_name", using: :btree

  create_table "ios_devices", force: :cascade do |t|
    t.string   "serial_number",       limit: 191
    t.string   "ip",                  limit: 191
    t.integer  "purpose",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "in_use"
    t.datetime "last_used"
    t.string   "ios_version",         limit: 191
    t.text     "description",         limit: 65535
    t.integer  "softlayer_proxy_id",  limit: 4
    t.integer  "ios_device_model_id", limit: 4
    t.string   "ios_version_fmt",     limit: 191
    t.boolean  "disabled",                          default: false
    t.integer  "open_proxy_id",       limit: 4
    t.integer  "apple_account_id",    limit: 4
  end

  add_index "ios_devices", ["apple_account_id"], name: "index_ios_devices_on_apple_account_id", using: :btree
  add_index "ios_devices", ["disabled"], name: "index_ios_devices_on_disabled", using: :btree
  add_index "ios_devices", ["ios_device_model_id"], name: "index_ios_devices_on_ios_device_model_id", using: :btree
  add_index "ios_devices", ["ip"], name: "index_ios_devices_on_ip", using: :btree
  add_index "ios_devices", ["last_used"], name: "index_ios_devices_on_last_used", using: :btree
  add_index "ios_devices", ["open_proxy_id"], name: "index_ios_devices_on_open_proxy_id", using: :btree
  add_index "ios_devices", ["purpose", "disabled"], name: "index_ios_devices_on_purpose_and_disabled", using: :btree
  add_index "ios_devices", ["serial_number"], name: "index_ios_devices_on_serial_number", using: :btree
  add_index "ios_devices", ["softlayer_proxy_id"], name: "index_ios_devices_on_softlayer_proxy_id", using: :btree

  create_table "ios_email_accounts", force: :cascade do |t|
    t.string   "email",      limit: 191
    t.string   "password",   limit: 191
    t.boolean  "flagged",                default: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_email_accounts", ["email"], name: "index_ios_email_accounts_on_email", unique: true, using: :btree

  create_table "ios_fb_ad_appearances", force: :cascade do |t|
    t.string   "aws_assignment_identifier", limit: 191
    t.string   "hit_identifier",            limit: 191
    t.integer  "heroku_identifier",         limit: 4
    t.integer  "m_turk_worker_id",          limit: 4
    t.integer  "ios_app_id",                limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_fb_ad_appearances", ["aws_assignment_identifier"], name: "index_ios_fb_ad_appearances_on_aws_assignment_identifier", using: :btree
  add_index "ios_fb_ad_appearances", ["hit_identifier"], name: "index_ios_fb_ad_appearances_on_hit_identifier", using: :btree
  add_index "ios_fb_ad_appearances", ["ios_app_id"], name: "index_ios_fb_ad_appearances_on_ios_app_id", using: :btree
  add_index "ios_fb_ad_appearances", ["m_turk_worker_id"], name: "index_ios_fb_ad_appearances_on_m_turk_worker_id", using: :btree

  create_table "ios_fb_ad_exceptions", force: :cascade do |t|
    t.integer  "ios_fb_ad_job_id", limit: 4
    t.integer  "fb_account_id",    limit: 4
    t.integer  "ios_device_id",    limit: 4
    t.text     "error",            limit: 65535
    t.text     "backtrace",        limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_fb_ad_exceptions", ["fb_account_id"], name: "index_ios_fb_ad_exceptions_on_fb_account_id", using: :btree
  add_index "ios_fb_ad_exceptions", ["ios_device_id"], name: "index_ios_fb_ad_exceptions_on_ios_device_id", using: :btree
  add_index "ios_fb_ad_exceptions", ["ios_fb_ad_job_id"], name: "index_ios_fb_ad_exceptions_on_ios_fb_ad_job_id", using: :btree

  create_table "ios_fb_ad_jobs", force: :cascade do |t|
    t.text     "notes",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "job_type",   limit: 4
  end

  add_index "ios_fb_ad_jobs", ["job_type"], name: "index_ios_fb_ad_jobs_on_job_type", using: :btree

  create_table "ios_fb_ad_processing_exceptions", force: :cascade do |t|
    t.integer  "ios_fb_ad_id", limit: 4
    t.text     "error",        limit: 65535
    t.text     "backtrace",    limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_fb_ad_processing_exceptions", ["ios_fb_ad_id"], name: "index_ios_fb_ad_processing_exceptions_on_ios_fb_ad_id", using: :btree

  create_table "ios_fb_ads", force: :cascade do |t|
    t.integer  "ios_fb_ad_job_id",           limit: 4
    t.integer  "ios_app_id",                 limit: 4
    t.integer  "fb_account_id",              limit: 4
    t.integer  "ios_device_id",              limit: 4
    t.integer  "status",                     limit: 4
    t.boolean  "flagged",                                  default: false
    t.text     "link_contents",              limit: 65535
    t.text     "ad_info_html",               limit: 65535
    t.integer  "feed_index",                 limit: 4
    t.boolean  "carousel"
    t.datetime "date_seen"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "ad_image_file_name",         limit: 191
    t.string   "ad_image_content_type",      limit: 191
    t.integer  "ad_image_file_size",         limit: 4
    t.datetime "ad_image_updated_at"
    t.string   "ad_info_image_file_name",    limit: 191
    t.string   "ad_info_image_content_type", limit: 191
    t.integer  "ad_info_image_file_size",    limit: 4
    t.datetime "ad_info_image_updated_at"
    t.integer  "ios_fb_ad_appearances_id",   limit: 4
    t.integer  "softlayer_proxy_id",         limit: 4
    t.integer  "open_proxy_id",              limit: 4
  end

  add_index "ios_fb_ads", ["date_seen"], name: "index_ios_fb_ads_on_date_seen", using: :btree
  add_index "ios_fb_ads", ["fb_account_id"], name: "index_ios_fb_ads_on_fb_account_id", using: :btree
  add_index "ios_fb_ads", ["ios_app_id", "status", "flagged"], name: "index_ios_fb_ads_on_ios_app_id_and_status_and_flagged", using: :btree
  add_index "ios_fb_ads", ["ios_device_id"], name: "index_ios_fb_ads_on_ios_device_id", using: :btree
  add_index "ios_fb_ads", ["ios_fb_ad_appearances_id"], name: "index_ios_fb_ads_on_ios_fb_ad_appearances_id", using: :btree
  add_index "ios_fb_ads", ["ios_fb_ad_job_id"], name: "index_ios_fb_ads_on_ios_fb_ad_job_id", using: :btree
  add_index "ios_fb_ads", ["open_proxy_id"], name: "index_ios_fb_ads_on_open_proxy_id", using: :btree
  add_index "ios_fb_ads", ["softlayer_proxy_id"], name: "index_ios_fb_ads_on_softlayer_proxy_id", using: :btree
  add_index "ios_fb_ads", ["status", "flagged"], name: "index_ios_fb_ads_on_status_and_flagged", using: :btree

  create_table "ios_in_app_purchases", force: :cascade do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name",                limit: 191
    t.integer  "ios_app_snapshot_id", limit: 4
    t.integer  "price",               limit: 4
  end

  add_index "ios_in_app_purchases", ["ios_app_snapshot_id"], name: "index_ios_in_app_purchases_on_ios_app_snapshot_id", using: :btree

  create_table "ios_reclassification_methods", force: :cascade do |t|
    t.integer  "method",     limit: 4
    t.boolean  "active"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "ios_reclassification_methods", ["active"], name: "index_ios_reclassification_methods_on_active", using: :btree
  add_index "ios_reclassification_methods", ["method"], name: "index_ios_reclassification_methods_on_method", unique: true, using: :btree

  create_table "ios_sdk_badges", force: :cascade do |t|
    t.integer  "ios_sdk_id", limit: 4
    t.string   "username",   limit: 191
    t.string   "repo_name",  limit: 191
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "ios_sdk_badges", ["ios_sdk_id"], name: "index_ios_sdk_badges_on_ios_sdk_id", using: :btree
  add_index "ios_sdk_badges", ["repo_name"], name: "index_ios_sdk_badges_on_repo_name", using: :btree
  add_index "ios_sdk_badges", ["username", "repo_name"], name: "index_ios_sdk_badges_on_username_and_repo_name", unique: true, using: :btree

  create_table "ios_sdk_links", force: :cascade do |t|
    t.integer  "source_sdk_id", limit: 4, null: false
    t.integer  "dest_sdk_id",   limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_sdk_links", ["dest_sdk_id"], name: "index_ios_sdk_links_on_dest_sdk_id", using: :btree
  add_index "ios_sdk_links", ["source_sdk_id"], name: "index_ios_sdk_links_on_source_sdk_id", unique: true, using: :btree

  create_table "ios_sdk_source_data", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.integer  "ios_sdk_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "flagged",                default: false
  end

  add_index "ios_sdk_source_data", ["flagged"], name: "index_ios_sdk_source_data_on_flagged", using: :btree
  add_index "ios_sdk_source_data", ["ios_sdk_id"], name: "index_ios_sdk_source_data_on_ios_sdk_id", using: :btree
  add_index "ios_sdk_source_data", ["name", "flagged"], name: "index_ios_sdk_source_data_on_name_and_flagged", using: :btree

  create_table "ios_sdk_source_groups", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.integer  "ios_sdk_id", limit: 4
    t.boolean  "flagged"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_sdk_source_groups", ["ios_sdk_id"], name: "index_ios_sdk_source_groups_on_ios_sdk_id", using: :btree

  create_table "ios_sdk_source_matches", force: :cascade do |t|
    t.integer  "source_sdk_id", limit: 4
    t.integer  "match_sdk_id",  limit: 4
    t.integer  "collisions",    limit: 4
    t.integer  "total",         limit: 4
    t.float    "ratio",         limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_sdk_source_matches", ["ratio"], name: "index_ios_sdk_source_matches_on_ratio", using: :btree
  add_index "ios_sdk_source_matches", ["source_sdk_id"], name: "index_ios_sdk_source_matches_on_source_sdk_id", using: :btree

  create_table "ios_sdk_update_exceptions", force: :cascade do |t|
    t.string   "sdk_name",          limit: 191
    t.integer  "ios_sdk_update_id", limit: 4
    t.text     "error",             limit: 65535
    t.text     "backtrace",         limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_sdk_update_exceptions", ["ios_sdk_update_id"], name: "index_ios_sdk_update_exceptions_on_ios_sdk_update_id", using: :btree
  add_index "ios_sdk_update_exceptions", ["sdk_name"], name: "index_ios_sdk_update_exceptions_on_sdk_name", using: :btree

  create_table "ios_sdk_updates", force: :cascade do |t|
    t.string   "cocoapods_sha", limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_sdk_updates", ["cocoapods_sha"], name: "index_ios_sdk_updates_on_cocoapods_sha", using: :btree

  create_table "ios_sdks", force: :cascade do |t|
    t.string   "name",                    limit: 191
    t.string   "website",                 limit: 191
    t.string   "favicon",                 limit: 191
    t.boolean  "flagged",                               default: false
    t.boolean  "open_source"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "summary",                 limit: 65535
    t.boolean  "deprecated"
    t.integer  "github_repo_identifier",  limit: 4
    t.integer  "sdk_company_id",          limit: 4
    t.integer  "ios_sdk_source_group_id", limit: 4
    t.integer  "source",                  limit: 4
    t.integer  "kind",                    limit: 4
  end

  add_index "ios_sdks", ["deprecated"], name: "index_ios_sdks_on_deprecated", using: :btree
  add_index "ios_sdks", ["flagged"], name: "index_ios_sdks_on_flagged", using: :btree
  add_index "ios_sdks", ["github_repo_identifier"], name: "index_ios_sdks_on_github_repo_identifier", using: :btree
  add_index "ios_sdks", ["ios_sdk_source_group_id"], name: "index_ios_sdks_on_ios_sdk_source_group_id", using: :btree
  add_index "ios_sdks", ["kind"], name: "index_ios_sdks_on_kind", using: :btree
  add_index "ios_sdks", ["name"], name: "index_ios_sdks_on_name", unique: true, using: :btree
  add_index "ios_sdks", ["open_source"], name: "index_ios_sdks_on_open_source", using: :btree
  add_index "ios_sdks", ["sdk_company_id"], name: "index_ios_sdks_on_sdk_company_id", using: :btree
  add_index "ios_sdks", ["source"], name: "index_ios_sdks_on_source", using: :btree
  add_index "ios_sdks", ["website"], name: "index_ios_sdks_on_website", using: :btree

  create_table "ios_sdks_ipa_snapshots", force: :cascade do |t|
    t.integer  "ios_sdk_id",      limit: 4
    t.integer  "ipa_snapshot_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "method",          limit: 4
  end

  add_index "ios_sdks_ipa_snapshots", ["ios_sdk_id"], name: "ios_sdk_id", using: :btree
  add_index "ios_sdks_ipa_snapshots", ["ipa_snapshot_id", "ios_sdk_id", "method"], name: "index_ipa_snapshot_id_ios_sdk_id_method", unique: true, using: :btree

  create_table "ios_sdks_ms_clearbit_leads", force: :cascade do |t|
    t.integer  "ios_sdk_id",          limit: 4
    t.integer  "ms_clearbit_lead_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_sdks_ms_clearbit_leads", ["ios_sdk_id"], name: "index_ios_sdk_id", using: :btree
  add_index "ios_sdks_ms_clearbit_leads", ["ms_clearbit_lead_id", "ios_sdk_id"], name: "index_clearbit_id_ios_sdk_id", using: :btree

  create_table "ios_word_occurences", force: :cascade do |t|
    t.string   "word",       limit: 191
    t.integer  "count",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_word_occurences", ["count"], name: "index_ios_word_occurences_on_count", using: :btree
  add_index "ios_word_occurences", ["word"], name: "index_ios_word_occurences_on_word", using: :btree

  create_table "ipa_snapshot_exceptions", force: :cascade do |t|
    t.integer  "ipa_snapshot_id",     limit: 4
    t.integer  "ipa_snapshot_job_id", limit: 4
    t.integer  "error_code",          limit: 4
    t.text     "error",               limit: 65535
    t.text     "backtrace",           limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ipa_snapshot_exceptions", ["ipa_snapshot_id"], name: "index_ipa_snapshot_exceptions_on_ipa_snapshot_id", using: :btree

  create_table "ipa_snapshot_job_exceptions", force: :cascade do |t|
    t.integer  "ipa_snapshot_job_id", limit: 4
    t.text     "error",               limit: 65535
    t.text     "backtrace",           limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ios_app_id",          limit: 4
  end

  add_index "ipa_snapshot_job_exceptions", ["ipa_snapshot_job_id"], name: "index_ipa_snapshot_job_exceptions_on_ipa_snapshot_job_id", using: :btree

  create_table "ipa_snapshot_jobs", force: :cascade do |t|
    t.integer  "job_type",              limit: 4
    t.text     "notes",                 limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "live_scan_status",      limit: 4
    t.boolean  "international_enabled",               default: false
  end

  create_table "ipa_snapshot_lookup_failures", force: :cascade do |t|
    t.integer  "ipa_snapshot_job_id", limit: 4
    t.integer  "ios_app_id",          limit: 4
    t.integer  "reason",              limit: 4
    t.text     "lookup_content",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ipa_snapshot_lookup_failures", ["ios_app_id"], name: "index_ipa_snapshot_lookup_failures_on_ios_app_id", using: :btree
  add_index "ipa_snapshot_lookup_failures", ["ipa_snapshot_job_id"], name: "index_ipa_snapshot_lookup_failures_on_ipa_snapshot_job_id", using: :btree

  create_table "ipa_snapshots", force: :cascade do |t|
    t.integer  "ios_app_id",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "download_status",     limit: 4
    t.boolean  "success"
    t.integer  "ipa_snapshot_job_id", limit: 4
    t.integer  "scan_status",         limit: 4
    t.string   "version",             limit: 191
    t.datetime "good_as_of_date"
    t.string   "bundle_version",      limit: 191
    t.text     "lookup_content",      limit: 65535
    t.datetime "first_valid_date"
    t.integer  "app_store_id",        limit: 4
  end

  add_index "ipa_snapshots", ["app_store_id"], name: "index_ipa_snapshots_on_app_store_id", using: :btree
  add_index "ipa_snapshots", ["good_as_of_date"], name: "index_ipa_snapshots_on_good_as_of_date", using: :btree
  add_index "ipa_snapshots", ["ios_app_id", "good_as_of_date"], name: "index_ipa_snapshots_on_ios_app_id_and_good_as_of_date", using: :btree
  add_index "ipa_snapshots", ["ios_app_id", "scan_status"], name: "index_ipa_snapshots_on_ios_app_id_and_scan_status", using: :btree
  add_index "ipa_snapshots", ["ipa_snapshot_job_id", "ios_app_id"], name: "index_ipa_snapshots_on_ipa_snapshot_job_id_and_ios_app_id", unique: true, using: :btree
  add_index "ipa_snapshots", ["scan_status"], name: "index_ipa_snapshots_on_scan_status", using: :btree
  add_index "ipa_snapshots", ["success", "scan_status"], name: "index_ipa_snapshots_on_success_and_scan_status", using: :btree

  create_table "ipa_snapshots_sdk_dlls", force: :cascade do |t|
    t.integer  "ipa_snapshot_id", limit: 4
    t.integer  "sdk_dll_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ipa_snapshots_sdk_dlls", ["ipa_snapshot_id", "sdk_dll_id"], name: "index_ipa_snapshot_id_sdk_dll_id", unique: true, using: :btree
  add_index "ipa_snapshots_sdk_dlls", ["sdk_dll_id"], name: "index_ipa_snapshots_sdk_dlls_on_sdk_dll_id", using: :btree

  create_table "ipa_snapshots_sdk_js_tags", force: :cascade do |t|
    t.integer  "ipa_snapshot_id", limit: 4
    t.integer  "sdk_js_tag_id",   limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ipa_snapshots_sdk_js_tags", ["ipa_snapshot_id", "sdk_js_tag_id"], name: "index_ipa_snapshot_id_sdk_js_tag_id", unique: true, using: :btree
  add_index "ipa_snapshots_sdk_js_tags", ["sdk_js_tag_id"], name: "index_ipa_snapshots_sdk_js_tags_on_sdk_js_tag_id", using: :btree

  create_table "jp_ios_app_snapshots", force: :cascade do |t|
    t.string   "name",                           limit: 191
    t.integer  "price",                          limit: 4
    t.integer  "size",                           limit: 8
    t.string   "seller_url",                     limit: 191
    t.string   "support_url",                    limit: 191
    t.string   "version",                        limit: 191
    t.string   "recommended_age",                limit: 191
    t.text     "description",                    limit: 65535
    t.integer  "ios_app_id",                     limit: 4
    t.string   "required_ios_version",           limit: 191
    t.text     "release_notes",                  limit: 65535
    t.string   "seller",                         limit: 191
    t.integer  "developer_app_store_identifier", limit: 4
    t.decimal  "ratings_current_stars",                        precision: 3, scale: 2
    t.integer  "ratings_current_count",          limit: 4
    t.decimal  "ratings_all_stars",                            precision: 3, scale: 2
    t.integer  "ratings_all_count",              limit: 4
    t.integer  "status",                         limit: 4
    t.integer  "job_identifier",                 limit: 4
    t.string   "category",                       limit: 191
    t.integer  "user_base",                      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "business_country_code",          limit: 191
    t.string   "business_country",               limit: 191
  end

  add_index "jp_ios_app_snapshots", ["business_country"], name: "index_jp_ios_app_snapshots_on_business_country", using: :btree
  add_index "jp_ios_app_snapshots", ["business_country_code"], name: "index_jp_ios_app_snapshots_on_business_country_code", using: :btree
  add_index "jp_ios_app_snapshots", ["developer_app_store_identifier"], name: "index_jp_ios_app_snapshots_on_developer_app_store_identifier", using: :btree
  add_index "jp_ios_app_snapshots", ["ios_app_id"], name: "index_jp_ios_app_snapshots_on_ios_app_id", using: :btree
  add_index "jp_ios_app_snapshots", ["job_identifier"], name: "index_jp_ios_app_snapshots_on_job_identifier", using: :btree
  add_index "jp_ios_app_snapshots", ["name"], name: "index_jp_ios_app_snapshots_on_name", using: :btree
  add_index "jp_ios_app_snapshots", ["user_base"], name: "index_jp_ios_app_snapshots_on_user_base", using: :btree

  create_table "js_tag_regexes", force: :cascade do |t|
    t.text     "regex",          limit: 65535
    t.integer  "android_sdk_id", limit: 4
    t.integer  "ios_sdk_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "js_tag_regexes", ["android_sdk_id"], name: "index_js_tag_regexes_on_android_sdk_id", using: :btree
  add_index "js_tag_regexes", ["ios_sdk_id"], name: "index_js_tag_regexes_on_ios_sdk_id", using: :btree

  create_table "known_ios_words", force: :cascade do |t|
    t.string "word", limit: 191
  end

  add_index "known_ios_words", ["word"], name: "index_known_ios_words_on_word", using: :btree

  create_table "leads", force: :cascade do |t|
    t.string   "email",       limit: 191
    t.string   "first_name",  limit: 191
    t.string   "last_name",   limit: 191
    t.string   "company",     limit: 191
    t.string   "phone",       limit: 191
    t.string   "crm",         limit: 191
    t.string   "sdk",         limit: 191
    t.text     "message",     limit: 65535
    t.string   "lead_source", limit: 191
    t.text     "lead_data",   limit: 65535
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "leads", ["email"], name: "index_leads_on_email", using: :btree

  create_table "listables_lists", force: :cascade do |t|
    t.integer  "listable_id",   limit: 4
    t.integer  "list_id",       limit: 4
    t.string   "listable_type", limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "listables_lists", ["list_id"], name: "index_listables_lists_on_list_id", using: :btree
  add_index "listables_lists", ["listable_id", "list_id", "listable_type"], name: "index_listable_id_list_id_listable_type", using: :btree
  add_index "listables_lists", ["listable_type"], name: "index_listables_lists_on_listable_type", using: :btree

  create_table "lists", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.text     "filter",     limit: 65535
  end

  create_table "lists_users", force: :cascade do |t|
    t.integer  "user_id",    limit: 4
    t.integer  "list_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "lists_users", ["list_id", "user_id"], name: "index_lists_users_on_list_id_and_user_id", using: :btree
  add_index "lists_users", ["user_id"], name: "index_lists_users_on_user_id", using: :btree

  create_table "m_turk_workers", force: :cascade do |t|
    t.string   "aws_identifier",    limit: 191
    t.integer  "age",               limit: 4
    t.string   "gender",            limit: 191
    t.string   "city",              limit: 191
    t.string   "state",             limit: 191
    t.string   "country",           limit: 191
    t.string   "iphone",            limit: 191
    t.string   "ios_version",       limit: 191
    t.string   "heroku_identifier", limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "m_turk_workers", ["aws_identifier"], name: "index_m_turk_workers_on_aws_identifier", using: :btree

  create_table "manual_app_developers", force: :cascade do |t|
    t.string   "name",                  limit: 191
    t.text     "ios_developer_ids",     limit: 65535
    t.text     "android_developer_ids", limit: 65535
    t.boolean  "flagged",                             default: false
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  add_index "manual_app_developers", ["name"], name: "index_manual_app_developers_on_name", using: :btree

  create_table "matchers", force: :cascade do |t|
    t.integer  "service_id",   limit: 4
    t.integer  "match_type",   limit: 4
    t.text     "match_string", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "matchers", ["service_id"], name: "index_matchers_on_service_id", using: :btree

  create_table "micro_proxies", force: :cascade do |t|
    t.boolean  "active"
    t.string   "public_ip",  limit: 191
    t.string   "private_ip", limit: 191
    t.date     "last_used"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "purpose",    limit: 4
    t.integer  "region",     limit: 4
  end

  add_index "micro_proxies", ["active"], name: "index_micro_proxies_on_active", using: :btree
  add_index "micro_proxies", ["last_used"], name: "index_micro_proxies_on_last_used", using: :btree
  add_index "micro_proxies", ["private_ip"], name: "index_micro_proxies_on_private_ip", using: :btree
  add_index "micro_proxies", ["public_ip"], name: "index_micro_proxies_on_public_ip", using: :btree
  add_index "micro_proxies", ["purpose", "active"], name: "index_micro_proxies_on_purpose_and_active", using: :btree
  add_index "micro_proxies", ["purpose", "region", "active"], name: "index_micro_proxies_on_purpose_and_region_and_active", using: :btree

  create_table "ms_clearbit_leads", force: :cascade do |t|
    t.text     "first_name",   limit: 65535
    t.text     "last_name",    limit: 65535
    t.text     "full_name",    limit: 65535
    t.text     "title",        limit: 65535
    t.text     "email",        limit: 65535
    t.text     "linkedin",     limit: 65535
    t.text     "json_content", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "oauth_users", force: :cascade do |t|
    t.string   "provider",      limit: 191
    t.string   "uid",           limit: 191
    t.string   "name",          limit: 191
    t.string   "oauth_token",   limit: 191
    t.string   "refresh_token", limit: 191
    t.string   "instance_url",  limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email",         limit: 191
  end

  create_table "open_proxies", force: :cascade do |t|
    t.string   "public_ip",  limit: 191
    t.string   "username",   limit: 191
    t.string   "password",   limit: 191
    t.integer  "port",       limit: 4
    t.integer  "kind",       limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "open_proxies", ["kind"], name: "index_open_proxies_on_kind", using: :btree
  add_index "open_proxies", ["public_ip"], name: "index_open_proxies_on_public_ip", using: :btree

  create_table "owner_twitter_handles", force: :cascade do |t|
    t.integer  "twitter_handle_id", limit: 4
    t.integer  "owner_id",          limit: 4
    t.string   "owner_type",        limit: 191
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "owner_twitter_handles", ["owner_id"], name: "index_owner_twitter_handles_on_owner_id", using: :btree
  add_index "owner_twitter_handles", ["owner_type", "owner_id", "twitter_handle_id"], name: "index_owner_twitter_handle_poly_join", using: :btree
  add_index "owner_twitter_handles", ["owner_type", "owner_id"], name: "index_owner_twitter_handles_on_owner_type_and_owner_id", using: :btree
  add_index "owner_twitter_handles", ["twitter_handle_id"], name: "index_owner_twitter_handles_on_twitter_handle_id", using: :btree

  create_table "proxies", force: :cascade do |t|
    t.boolean  "active"
    t.string   "public_ip",  limit: 191
    t.string   "private_ip", limit: 191
    t.datetime "last_used"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "proxies", ["active"], name: "index_proxies_on_active", using: :btree
  add_index "proxies", ["last_used"], name: "index_proxies_on_last_used", using: :btree
  add_index "proxies", ["private_ip"], name: "index_proxies_on_private_ip", using: :btree

  create_table "scrape_jobs", force: :cascade do |t|
    t.text     "notes",      limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scraped_results", force: :cascade do |t|
    t.integer  "company_id",    limit: 4
    t.string   "url",           limit: 191
    t.text     "raw_html",      limit: 65535
    t.integer  "status",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "scrape_job_id", limit: 4
  end

  add_index "scraped_results", ["company_id"], name: "index_scraped_results_on_company_id", using: :btree
  add_index "scraped_results", ["scrape_job_id"], name: "index_scraped_results_on_scrape_job_id", using: :btree

  create_table "sdk_companies", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.string   "website",    limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "favicon",    limit: 65535
    t.boolean  "flagged",                  default: false
  end

  add_index "sdk_companies", ["flagged"], name: "index_sdk_companies_on_flagged", using: :btree
  add_index "sdk_companies", ["name"], name: "index_sdk_companies_on_name", unique: true, using: :btree
  add_index "sdk_companies", ["website"], name: "index_sdk_companies_on_website", unique: true, using: :btree

  create_table "sdk_dlls", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sdk_dlls", ["name"], name: "index_sdk_dlls_on_name", using: :btree

  create_table "sdk_file_regexes", force: :cascade do |t|
    t.text     "regex",          limit: 65535
    t.integer  "android_sdk_id", limit: 4
    t.integer  "ios_sdk_id",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sdk_file_regexes", ["android_sdk_id"], name: "index_sdk_file_regexes_on_android_sdk_id", using: :btree
  add_index "sdk_file_regexes", ["ios_sdk_id"], name: "index_sdk_file_regexes_on_ios_sdk_id", using: :btree

  create_table "sdk_js_tags", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sdk_js_tags", ["name"], name: "index_sdk_js_tags_on_name", unique: true, using: :btree

  create_table "sdk_packages", force: :cascade do |t|
    t.string   "package",        limit: 191
    t.integer  "ios_sdk_id",     limit: 4
    t.integer  "android_sdk_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sdk_packages", ["android_sdk_id"], name: "index_sdk_packages_on_android_sdk_id", using: :btree
  add_index "sdk_packages", ["ios_sdk_id"], name: "index_sdk_packages_on_ios_sdk_id", using: :btree
  add_index "sdk_packages", ["package"], name: "index_sdk_packages_on_package", unique: true, using: :btree

  create_table "sdk_packages_apk_snapshots", force: :cascade do |t|
    t.integer  "sdk_package_id",  limit: 4
    t.integer  "apk_snapshot_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sdk_packages_apk_snapshots", ["apk_snapshot_id"], name: "index_apk_snapshot_id", using: :btree
  add_index "sdk_packages_apk_snapshots", ["sdk_package_id", "apk_snapshot_id"], name: "index_sdk_package_id_apk_snapshot_id", unique: true, using: :btree
  add_index "sdk_packages_apk_snapshots", ["sdk_package_id"], name: "sdk_package_id", using: :btree

  create_table "sdk_packages_ipa_snapshots", force: :cascade do |t|
    t.integer  "sdk_package_id",  limit: 4
    t.integer  "ipa_snapshot_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sdk_packages_ipa_snapshots", ["sdk_package_id", "ipa_snapshot_id"], name: "index_sdk_package_id_ipa_snapshot_id", unique: true, using: :btree
  add_index "sdk_packages_ipa_snapshots", ["sdk_package_id"], name: "sdk_package_id", using: :btree

  create_table "sdk_regexes", force: :cascade do |t|
    t.string   "regex",          limit: 191
    t.integer  "ios_sdk_id",     limit: 4
    t.integer  "android_sdk_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sdk_regexes", ["android_sdk_id"], name: "index_sdk_regexes_on_android_sdk_id", using: :btree
  add_index "sdk_regexes", ["ios_sdk_id"], name: "index_sdk_regexes_on_ios_sdk_id", using: :btree
  add_index "sdk_regexes", ["regex"], name: "index_sdk_regexes_on_regex", unique: true, using: :btree

  create_table "sdk_scrapers", force: :cascade do |t|
    t.string   "name",                     limit: 191
    t.string   "private_ip",               limit: 191
    t.integer  "concurrent_apk_downloads", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sdk_scrapers", ["concurrent_apk_downloads"], name: "index_sdk_scrapers_on_concurrent_apk_downloads", using: :btree
  add_index "sdk_scrapers", ["private_ip"], name: "index_sdk_scrapers_on_private_ip", using: :btree

  create_table "sdk_string_regexes", force: :cascade do |t|
    t.text     "regex",       limit: 65535
    t.integer  "min_matches", limit: 4,     default: 0
    t.integer  "ios_sdk_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sdk_string_regexes", ["ios_sdk_id"], name: "index_sdk_string_regexes_on_ios_sdk_id", using: :btree

  create_table "service_statuses", force: :cascade do |t|
    t.integer  "service",        limit: 4,                    null: false
    t.boolean  "active",                       default: true
    t.text     "description",    limit: 65535
    t.text     "outage_message", limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "service_statuses", ["service"], name: "index_service_statuses_on_service", unique: true, using: :btree

  create_table "services", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.string   "website",    limit: 191
    t.string   "category",   limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "softlayer_proxies", force: :cascade do |t|
    t.string   "public_ip",  limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "host",       limit: 4
  end

  add_index "softlayer_proxies", ["host"], name: "index_softlayer_proxies_on_host", using: :btree
  add_index "softlayer_proxies", ["public_ip"], name: "index_softlayer_proxies_on_public_ip", using: :btree

  create_table "super_proxies", force: :cascade do |t|
    t.boolean  "active"
    t.string   "public_ip",  limit: 191
    t.string   "private_ip", limit: 191
    t.integer  "port",       limit: 4
    t.datetime "last_used"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "super_proxies", ["active"], name: "index_super_proxies_on_active", using: :btree
  add_index "super_proxies", ["last_used"], name: "index_super_proxies_on_last_used", using: :btree
  add_index "super_proxies", ["port", "private_ip"], name: "index_super_proxies_on_port_and_private_ip", using: :btree
  add_index "super_proxies", ["port"], name: "index_super_proxies_on_port", using: :btree
  add_index "super_proxies", ["private_ip"], name: "index_super_proxies_on_private_ip", using: :btree
  add_index "super_proxies", ["public_ip"], name: "index_super_proxies_on_public_ip", using: :btree

  create_table "tag_relationships", force: :cascade do |t|
    t.integer  "tag_id",        limit: 4
    t.integer  "taggable_id",   limit: 4
    t.string   "taggable_type", limit: 191
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "tag_relationships", ["tag_id", "taggable_id", "taggable_type"], name: "index_on_tag_id_and_taggable_id_and_type", using: :btree
  add_index "tag_relationships", ["tag_id"], name: "index_tag_relationships_on_tag_id", using: :btree
  add_index "tag_relationships", ["taggable_type", "taggable_id"], name: "index_tag_relationships_on_taggable_type_and_taggable_id", using: :btree

  create_table "tags", force: :cascade do |t|
    t.string   "name",       limit: 191
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "test_models", force: :cascade do |t|
    t.string   "string0",    limit: 191
    t.string   "string1",    limit: 191
    t.string   "string2",    limit: 191
    t.string   "string3",    limit: 191
    t.string   "string4",    limit: 191
    t.string   "string5",    limit: 191
    t.string   "string6",    limit: 191
    t.string   "string7",    limit: 191
    t.string   "string8",    limit: 191
    t.string   "string9",    limit: 191
    t.string   "string10",   limit: 191
    t.string   "string11",   limit: 191
    t.string   "string12",   limit: 191
    t.string   "string13",   limit: 191
    t.string   "string14",   limit: 191
    t.string   "string15",   limit: 191
    t.string   "string16",   limit: 191
    t.string   "string17",   limit: 191
    t.string   "string18",   limit: 191
    t.string   "string19",   limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "text0",      limit: 65535
    t.text     "text1",      limit: 65535
    t.text     "text2",      limit: 65535
  end

  add_index "test_models", ["string0"], name: "index_test_models_on_string0", using: :btree
  add_index "test_models", ["string1"], name: "index_test_models_on_string1", using: :btree
  add_index "test_models", ["string10"], name: "index_test_models_on_string10", using: :btree
  add_index "test_models", ["string11"], name: "index_test_models_on_string11", using: :btree
  add_index "test_models", ["string12"], name: "index_test_models_on_string12", using: :btree
  add_index "test_models", ["string13"], name: "index_test_models_on_string13", using: :btree
  add_index "test_models", ["string14"], name: "index_test_models_on_string14", using: :btree
  add_index "test_models", ["string15"], name: "index_test_models_on_string15", using: :btree
  add_index "test_models", ["string16"], name: "index_test_models_on_string16", using: :btree
  add_index "test_models", ["string17"], name: "index_test_models_on_string17", using: :btree
  add_index "test_models", ["string18"], name: "index_test_models_on_string18", using: :btree
  add_index "test_models", ["string19"], name: "index_test_models_on_string19", using: :btree
  add_index "test_models", ["string2"], name: "index_test_models_on_string2", using: :btree
  add_index "test_models", ["string3"], name: "index_test_models_on_string3", using: :btree
  add_index "test_models", ["string4"], name: "index_test_models_on_string4", using: :btree
  add_index "test_models", ["string5"], name: "index_test_models_on_string5", using: :btree
  add_index "test_models", ["string6"], name: "index_test_models_on_string6", using: :btree
  add_index "test_models", ["string7"], name: "index_test_models_on_string7", using: :btree
  add_index "test_models", ["string8"], name: "index_test_models_on_string8", using: :btree
  add_index "test_models", ["string9"], name: "index_test_models_on_string9", using: :btree

  create_table "twitter_handles", force: :cascade do |t|
    t.string   "handle",     limit: 191
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "twitter_handles", ["handle"], name: "index_twitter_handles_on_handle", unique: true, using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",           limit: 191
    t.string   "password_digest", limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "account_id",      limit: 4
    t.boolean  "tos_accepted",                default: false
    t.boolean  "access_revoked",              default: false
    t.boolean  "is_admin",                    default: false
    t.string   "google_uid",      limit: 191
    t.string   "google_token",    limit: 191
    t.string   "linkedin_uid",    limit: 191
    t.string   "linkedin_token",  limit: 191
    t.datetime "last_active"
    t.string   "first_name",      limit: 191
    t.string   "last_name",       limit: 191
    t.string   "profile_url",     limit: 191
    t.string   "refresh_token",   limit: 191
  end

  add_index "users", ["account_id"], name: "index_users_on_account_id", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["tos_accepted"], name: "index_users_on_tos_accepted", using: :btree

  create_table "users_countries", force: :cascade do |t|
    t.integer  "user_id",      limit: 4
    t.string   "country_code", limit: 191
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "users_countries", ["country_code"], name: "index_users_countries_on_country_code", using: :btree
  add_index "users_countries", ["user_id", "country_code"], name: "index_users_countries_on_user_id_and_country_code", unique: true, using: :btree

  create_table "website_features", force: :cascade do |t|
    t.integer  "user_id",   limit: 4
    t.integer  "name",      limit: 4
    t.datetime "last_used"
  end

  add_index "website_features", ["user_id"], name: "index_website_features_on_user_id", using: :btree

  create_table "websites", force: :cascade do |t|
    t.string   "url",          limit: 191
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "kind",         limit: 4
    t.integer  "company_id",   limit: 4
    t.integer  "ios_app_id",   limit: 4
    t.string   "match_string", limit: 191
  end

  add_index "websites", ["company_id"], name: "index_websites_on_company_id", using: :btree
  add_index "websites", ["id", "company_id"], name: "index_websites_on_id_and_company_id", using: :btree
  add_index "websites", ["ios_app_id"], name: "index_websites_on_ios_app_id", using: :btree
  add_index "websites", ["kind"], name: "index_websites_on_kind", using: :btree
  add_index "websites", ["match_string"], name: "index_websites_on_match_string", using: :btree
  add_index "websites", ["url"], name: "index_websites_on_url", unique: true, using: :btree

  create_table "websites_domain_data", force: :cascade do |t|
    t.integer  "website_id",      limit: 4
    t.integer  "domain_datum_id", limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "websites_domain_data", ["domain_datum_id"], name: "index_websites_domain_data_on_domain_datum_id", using: :btree
  add_index "websites_domain_data", ["website_id", "domain_datum_id"], name: "index_websites_domain_data_on_website_id_and_domain_datum_id", using: :btree

  create_table "weekly_batches", force: :cascade do |t|
    t.integer  "owner_id",         limit: 4
    t.string   "owner_type",       limit: 191
    t.integer  "activity_type",    limit: 4
    t.integer  "activities_count", limit: 4,   default: 0, null: false
    t.date     "week",                                     null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "weekly_batches", ["activity_type"], name: "index_weekly_batches_on_activity_type", using: :btree
  add_index "weekly_batches", ["owner_id", "owner_type"], name: "index_weekly_batches_on_owner_id_and_owner_type", using: :btree
  add_index "weekly_batches", ["week"], name: "index_weekly_batches_on_week", using: :btree

  create_table "weekly_batches_activities", force: :cascade do |t|
    t.integer  "weekly_batch_id", limit: 4, null: false
    t.integer  "activity_id",     limit: 4, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "weekly_batches_activities", ["activity_id"], name: "index_weekly_batches_activities_on_activity_id", using: :btree
  add_index "weekly_batches_activities", ["weekly_batch_id", "activity_id"], name: "weekly_batch_id_activity_id_index", using: :btree

  create_table "word_occurences", force: :cascade do |t|
    t.string   "word",       limit: 191
    t.integer  "good",       limit: 4
    t.integer  "bad",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "word_occurences", ["word"], name: "index_word_occurences_on_word", using: :btree

end
