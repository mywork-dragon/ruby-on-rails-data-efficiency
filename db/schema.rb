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

ActiveRecord::Schema.define(version: 20150327233405) do

  create_table "android_app_download_ranges", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "android_app_release_id"
    t.integer  "min"
    t.integer  "max"
  end

  create_table "android_app_releases", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "category"
    t.integer  "price"
    t.integer  "size"
    t.date     "updated"
    t.string   "seller_url"
    t.string   "version"
    t.date     "released"
    t.text     "description"
    t.string   "link"
    t.integer  "android_app_id"
    t.integer  "previous_release_id"
    t.integer  "google_plus_likes"
    t.boolean  "top_dev"
    t.boolean  "in_app_purchases"
    t.string   "required_android_version"
    t.string   "content_rating"
  end

  create_table "android_app_review_snapshots", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "android_app_release_id"
    t.float    "average",                limit: 24
    t.integer  "total"
    t.integer  "stars5"
    t.integer  "stars4"
    t.integer  "stars3"
    t.integer  "stars2"
    t.integer  "stars1"
  end

  create_table "android_apps", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "app_identifier"
    t.integer  "app_id"
  end

  add_index "android_apps", ["app_identifier"], name: "index_android_apps_on_app_identifier", using: :btree

  create_table "android_in_app_purchase_ranges", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "android_app_release_id"
    t.integer  "min"
    t.integer  "max"
  end

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
    t.string   "app_store_identifier"
  end

  add_index "companies", ["status"], name: "index_companies_on_status", using: :btree
  add_index "companies", ["website"], name: "index_companies_on_website", unique: true, using: :btree

  create_table "delayed_jobs", force: true do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority", using: :btree

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

  create_table "ios_app_releases", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "category"
    t.integer  "price"
    t.integer  "size"
    t.date     "updated"
    t.string   "seller_url"
    t.string   "support_url"
    t.string   "version"
    t.date     "released"
    t.string   "recommended_age"
    t.text     "description"
    t.string   "link"
    t.integer  "ios_app_id"
    t.integer  "previous_release_id"
    t.boolean  "in_app_purchases"
    t.string   "required_ios_version"
  end

  create_table "ios_apps", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "app_identifier"
    t.integer  "app_id"
    t.integer  "downloads"
  end

  add_index "ios_apps", ["app_identifier"], name: "index_ios_apps_on_app_identifier", using: :btree

  create_table "ios_in_app_purchases", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "ios_app_release_id"
    t.integer  "price"
  end

  create_table "languages", force: true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
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

end
