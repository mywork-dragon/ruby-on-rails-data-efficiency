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

ActiveRecord::Schema.define(version: 20140920201458) do

  create_table "companies", force: true do |t|
    t.string   "name"
    t.string   "website"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "companies", ["website"], name: "index_companies_on_website", unique: true, using: :btree

  create_table "installations", force: true do |t|
    t.integer  "company_id"
    t.integer  "service_id"
    t.integer  "scraped_result_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "installations", ["company_id"], name: "index_installations_on_company_id", using: :btree
  add_index "installations", ["scraped_result_id"], name: "index_installations_on_scraped_result_id", using: :btree
  add_index "installations", ["service_id"], name: "index_installations_on_service_id", using: :btree

  create_table "matchers", force: true do |t|
    t.integer  "service_id"
    t.integer  "match_type"
    t.text     "match_string"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "matchers", ["service_id"], name: "index_matchers_on_service_id", using: :btree

  create_table "scraped_results", force: true do |t|
    t.integer  "company_id"
    t.string   "url"
    t.text     "raw_html"
    t.integer  "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "scraped_results", ["company_id"], name: "index_scraped_results_on_company_id", using: :btree

  create_table "services", force: true do |t|
    t.string   "name"
    t.string   "website"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
