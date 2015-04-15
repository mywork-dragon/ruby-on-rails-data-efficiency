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

ActiveRecord::Schema.define(version: 20150415200503) do

  create_table "android_app_categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "android_app_categories", ["name"], name: "index_android_app_categories_on_name", using: :btree

  create_table "android_app_categories_snapshots", force: true do |t|
    t.integer  "android_app_category_id"
    t.integer  "android_app_snapshot_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "kind"
  end

  add_index "android_app_categories_snapshots", ["android_app_category_id"], name: "index_android_app_category_id", using: :btree
  add_index "android_app_categories_snapshots", ["android_app_snapshot_id"], name: "index_android_app_snapshot_id", using: :btree

  create_table "android_app_snapshot_exceptions", force: true do |t|
    t.integer  "android_app_snapshot_id"
    t.text     "name"
    t.text     "backtrace"
    t.integer  "try"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "android_app_snapshot_job_id"
  end

  add_index "android_app_snapshot_exceptions", ["android_app_snapshot_id"], name: "index_android_app_snapshot_exceptions_on_android_app_snapshot_id", using: :btree
  add_index "android_app_snapshot_exceptions", ["android_app_snapshot_job_id"], name: "index_android_app_snapshot_job_id", using: :btree

  create_table "android_app_snapshot_jobs", force: true do |t|
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "android_app_snapshots", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "price"
    t.integer  "size",                             limit: 8
    t.date     "updated"
    t.string   "seller_url"
    t.string   "version"
    t.date     "released"
    t.text     "description"
    t.integer  "android_app_id"
    t.integer  "google_plus_likes"
    t.boolean  "top_dev"
    t.boolean  "in_app_purchases"
    t.string   "required_android_version"
    t.string   "content_rating"
    t.string   "seller"
    t.decimal  "ratings_all_stars",                          precision: 3, scale: 2
    t.integer  "ratings_all_count"
    t.integer  "status"
    t.integer  "android_app_snapshot_job_id"
    t.integer  "in_app_purchase_min"
    t.integer  "in_app_purchase_max"
    t.integer  "downloads_min",                    limit: 8
    t.integer  "downloads_max",                    limit: 8
    t.string   "icon_url_300x300"
    t.string   "developer_google_play_identifier"
  end

  add_index "android_app_snapshots", ["android_app_snapshot_job_id"], name: "index_android_app_snapshots_on_android_app_snapshot_job_id", using: :btree
  add_index "android_app_snapshots", ["developer_google_play_identifier"], name: "index_developer_google_play_identifier", using: :btree

  create_table "android_apps", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "app_identifier"
    t.integer  "app_id"
    t.integer  "newest_android_app_snapshot_id"
    t.string   "user_base"
    t.string   "mobile_priority"
  end

  add_index "android_apps", ["app_identifier"], name: "index_android_apps_on_app_identifier", using: :btree
  add_index "android_apps", ["mobile_priority"], name: "index_android_apps_on_mobile_priority", using: :btree
  add_index "android_apps", ["newest_android_app_snapshot_id"], name: "index_android_apps_on_newest_android_app_snapshot_id", using: :btree

  create_table "android_apps_websites", force: true do |t|
    t.integer  "android_app_id"
    t.integer  "website_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "android_apps_websites", ["android_app_id"], name: "index_android_apps_websites_on_android_app_id", using: :btree
  add_index "android_apps_websites", ["website_id"], name: "index_android_apps_websites_on_website_id", using: :btree

  create_table "apps", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.string   "name"
  end

  create_table "companies", force: true do |t|
    t.string   "name"
    t.string   "website"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "fortune_1000_rank"
    t.string   "ceo_name"
    t.string   "street_address"
    t.string   "city"
    t.string   "zip_code"
    t.string   "state"
    t.integer  "employee_count"
    t.string   "industry"
    t.string   "type"
    t.integer  "funding"
    t.integer  "inc_5000_rank"
    t.string   "country"
    t.integer  "app_store_identifier"
    t.string   "google_play_identifier"
  end

  add_index "companies", ["app_store_identifier"], name: "index_app_store_identifier", using: :btree
  add_index "companies", ["fortune_1000_rank"], name: "index_companies_on_fortune_1000_rank", using: :btree
  add_index "companies", ["google_play_identifier"], name: "index_google_play_identifier", using: :btree
  add_index "companies", ["status"], name: "index_companies_on_status", using: :btree
  add_index "companies", ["website"], name: "index_companies_on_website", unique: true, using: :btree

  create_table "fb_ad_appearances", force: true do |t|
    t.string   "aws_assignment_identifier"
    t.string   "hit_identifier"
    t.integer  "heroku_identifier"
    t.integer  "m_turk_worker_id"
    t.integer  "ios_app_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "fb_ad_appearances", ["aws_assignment_identifier"], name: "index_fb_ad_appearances_on_aws_assignment_identifier", using: :btree
  add_index "fb_ad_appearances", ["hit_identifier"], name: "index_fb_ad_appearances_on_hit_identifier", using: :btree

  create_table "installations", force: true do |t|
    t.integer  "company_id"
    t.integer  "service_id"
    t.integer  "scraped_result_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status"
    t.integer  "scrape_job_id"
  end

  add_index "installations", ["company_id", "created_at"], name: "index_installations_on_company_id_and_created_at", using: :btree
  add_index "installations", ["scrape_job_id"], name: "index_installations_on_scrape_job_id", using: :btree
  add_index "installations", ["scraped_result_id"], name: "index_installations_on_scraped_result_id", using: :btree
  add_index "installations", ["service_id", "created_at"], name: "index_installations_on_service_id_and_created_at", using: :btree
  add_index "installations", ["status", "created_at"], name: "index_installations_on_status_and_created_at", using: :btree

  create_table "ios_app_categories", force: true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ios_app_categories_snapshots", force: true do |t|
    t.integer  "ios_app_category_id"
    t.integer  "ios_app_snapshot_id"
    t.string   "kind"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_app_categories_snapshots", ["ios_app_category_id"], name: "index_ios_app_categories_snapshots_on_ios_app_category_id", using: :btree
  add_index "ios_app_categories_snapshots", ["ios_app_snapshot_id"], name: "index_ios_app_categories_snapshots_on_ios_app_snapshot_id", using: :btree

  create_table "ios_app_download_snapshot_exceptions", force: true do |t|
    t.integer  "ios_app_download_snapshot_id"
    t.text     "name"
    t.text     "backtrace"
    t.integer  "try"
    t.integer  "ios_app_download_snapshot_job_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_app_download_snapshot_exceptions", ["ios_app_download_snapshot_id"], name: "index_on_ios_app_download_snapshot_id", using: :btree
  add_index "ios_app_download_snapshot_exceptions", ["ios_app_download_snapshot_job_id"], name: "index_on_ios_app_download_snapshot_job_id", using: :btree

  create_table "ios_app_download_snapshot_jobs", force: true do |t|
    t.string   "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ios_app_download_snapshots", force: true do |t|
    t.integer  "downloads",                        limit: 8
    t.integer  "ios_app_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ios_app_download_snapshot_job_id"
    t.integer  "status"
  end

  add_index "ios_app_download_snapshots", ["ios_app_download_snapshot_job_id"], name: "index_on_ios_app_download_snapshot_job_id", using: :btree
  add_index "ios_app_download_snapshots", ["ios_app_id"], name: "index_ios_app_download_snapshots_on_ios_app_id", using: :btree
  add_index "ios_app_download_snapshots", ["status"], name: "index_ios_app_download_snapshots_on_status", using: :btree

  create_table "ios_app_languages", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
  end

  add_index "ios_app_languages", ["name"], name: "index_ios_app_languages_on_name", using: :btree

  create_table "ios_app_snapshot_exceptions", force: true do |t|
    t.integer  "ios_app_snapshot_id"
    t.text     "name"
    t.text     "backtrace"
    t.integer  "try"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "ios_app_snapshot_job_id"
  end

  add_index "ios_app_snapshot_exceptions", ["ios_app_snapshot_id"], name: "index_ios_app_snapshot_exceptions_on_ios_app_snapshot_id", using: :btree
  add_index "ios_app_snapshot_exceptions", ["ios_app_snapshot_job_id"], name: "index_ios_app_snapshot_job_id", using: :btree

  create_table "ios_app_snapshot_jobs", force: true do |t|
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "ios_app_snapshots", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "price"
    t.integer  "size",                            limit: 8
    t.string   "seller_url"
    t.string   "support_url"
    t.string   "version"
    t.date     "released"
    t.string   "recommended_age"
    t.text     "description"
    t.integer  "ios_app_id"
    t.string   "required_ios_version"
    t.integer  "ios_app_snapshot_job_id"
    t.text     "release_notes"
    t.string   "seller"
    t.integer  "developer_app_store_identifier"
    t.decimal  "ratings_current_stars",                     precision: 3,  scale: 2
    t.integer  "ratings_current_count"
    t.decimal  "ratings_all_stars",                         precision: 3,  scale: 2
    t.integer  "ratings_all_count"
    t.boolean  "editors_choice"
    t.integer  "status"
    t.text     "exception_backtrace"
    t.text     "exception"
    t.string   "icon_url_350x350"
    t.string   "icon_url_175x175"
    t.decimal  "ratings_per_day_current_release",           precision: 10, scale: 2
  end

  add_index "ios_app_snapshots", ["developer_app_store_identifier"], name: "index_ios_app_snapshots_on_developer_app_store_identifier", using: :btree
  add_index "ios_app_snapshots", ["ios_app_id"], name: "index_ios_app_snapshots_on_ios_app_id", using: :btree
  add_index "ios_app_snapshots", ["ios_app_snapshot_job_id"], name: "index_ios_app_snapshots_on_ios_app_snapshot_job_id", using: :btree

  create_table "ios_app_snapshots_languages", force: true do |t|
    t.integer  "ios_app_snapshot_id"
    t.integer  "language_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_app_snapshots_languages", ["ios_app_snapshot_id"], name: "index_ios_app_snapshots_languages_on_ios_app_snapshot_id", using: :btree
  add_index "ios_app_snapshots_languages", ["language_id"], name: "index_ios_app_snapshots_languages_on_language_id", using: :btree

  create_table "ios_apps", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "app_identifier"
    t.integer  "app_id"
    t.integer  "newest_ios_app_snapshot_id"
    t.string   "user_base"
    t.string   "mobile_priority"
  end

  add_index "ios_apps", ["app_identifier"], name: "index_ios_apps_on_app_identifier", using: :btree
  add_index "ios_apps", ["mobile_priority"], name: "index_ios_apps_on_mobile_priority", using: :btree
  add_index "ios_apps", ["newest_ios_app_snapshot_id"], name: "index_ios_apps_on_newest_ios_app_snapshot_id", using: :btree

  create_table "ios_apps_websites", force: true do |t|
    t.integer  "ios_app_id"
    t.integer  "website_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "ios_apps_websites", ["ios_app_id"], name: "index_ios_apps_websites_on_ios_app_id", using: :btree
  add_index "ios_apps_websites", ["website_id"], name: "index_ios_apps_websites_on_website_id", using: :btree

  create_table "ios_in_app_purchases", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "ios_app_snapshot_id"
    t.integer  "price"
  end

  create_table "m_turk_workers", force: true do |t|
    t.string   "aws_identifier"
    t.integer  "age"
    t.string   "gender"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.string   "iphone"
    t.string   "ios_version"
    t.string   "heroku_identifier"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "m_turk_workers", ["aws_identifier"], name: "index_m_turk_workers_on_aws_identifier", using: :btree

  create_table "matchers", force: true do |t|
    t.integer  "service_id"
    t.integer  "match_type"
    t.text     "match_string"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "matchers", ["service_id"], name: "index_matchers_on_service_id", using: :btree

  create_table "oauth_users", force: true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "oauth_token"
    t.string   "refresh_token"
    t.string   "instance_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
  end

  create_table "proxies", force: true do |t|
    t.boolean  "active"
    t.string   "public_ip"
    t.string   "private_ip"
    t.datetime "last_used"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "proxies", ["active"], name: "index_proxies_on_active", using: :btree
  add_index "proxies", ["last_used"], name: "index_proxies_on_last_used", using: :btree
  add_index "proxies", ["private_ip"], name: "index_proxies_on_private_ip", using: :btree

  create_table "scrape_jobs", force: true do |t|
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "scraped_results", force: true do |t|
    t.integer  "company_id"
    t.string   "url"
    t.text     "raw_html"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "scrape_job_id"
  end

  add_index "scraped_results", ["company_id"], name: "index_scraped_results_on_company_id", using: :btree
  add_index "scraped_results", ["scrape_job_id"], name: "index_scraped_results_on_scrape_job_id", using: :btree

  create_table "services", force: true do |t|
    t.string   "name"
    t.string   "website"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sidekiq_testers", force: true do |t|
    t.string   "test_string"
    t.string   "ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "websites", force: true do |t|
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "kind"
    t.integer  "company_id"
    t.integer  "ios_app_id"
  end

  add_index "websites", ["company_id"], name: "index_websites_on_company_id", using: :btree
  add_index "websites", ["ios_app_id"], name: "index_websites_on_ios_app_id", using: :btree
  add_index "websites", ["kind"], name: "index_websites_on_kind", using: :btree
  add_index "websites", ["url"], name: "index_websites_on_url", using: :btree

end
