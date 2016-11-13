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

ActiveRecord::Schema.define(version: 20161113182852) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "friendly_id_slugs", force: :cascade do |t|
    t.string   "slug",           limit: 255, null: false
    t.integer  "sluggable_id",               null: false
    t.string   "sluggable_type", limit: 50
    t.string   "scope",          limit: 255
    t.datetime "created_at"
  end

  add_index "friendly_id_slugs", ["slug", "sluggable_type", "scope"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope", unique: true, using: :btree
  add_index "friendly_id_slugs", ["slug", "sluggable_type"], name: "index_friendly_id_slugs_on_slug_and_sluggable_type", using: :btree
  add_index "friendly_id_slugs", ["sluggable_id"], name: "index_friendly_id_slugs_on_sluggable_id", using: :btree
  add_index "friendly_id_slugs", ["sluggable_type"], name: "index_friendly_id_slugs_on_sluggable_type", using: :btree

  create_table "projected_races", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.date     "date"
    t.float    "distance"
    t.integer  "temperature"
    t.integer  "humidity"
    t.string   "date_and_time",    limit: 255
    t.string   "location",         limit: 255
    t.string   "weather",          limit: 255
    t.string   "sponsor",          limit: 255
    t.boolean  "club_points",                  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",             limit: 255
    t.hstore   "men_results",                                  array: true
    t.hstore   "women_results",                                array: true
    t.hstore   "men_40_results",                               array: true
    t.hstore   "women_40_results",                             array: true
    t.hstore   "men_50_results",                               array: true
    t.hstore   "women_50_results",                             array: true
    t.hstore   "men_60_results",                               array: true
    t.hstore   "women_60_results",                             array: true
  end

  add_index "projected_races", ["slug"], name: "index_projected_races_on_slug", unique: true, using: :btree

  create_table "projected_results", force: :cascade do |t|
    t.string   "last_name",         limit: 255
    t.string   "first_name",        limit: 255
    t.string   "sex",               limit: 255
    t.integer  "age"
    t.integer  "bib"
    t.string   "team",              limit: 255
    t.string   "city",              limit: 255
    t.string   "state",             limit: 255
    t.string   "country",           limit: 255
    t.integer  "overall_place"
    t.integer  "gender_place"
    t.integer  "age_place"
    t.string   "net_time",          limit: 255
    t.string   "pace_per_mile",     limit: 255
    t.string   "ag_time",           limit: 255
    t.integer  "ag_gender_place"
    t.float    "ag_percent"
    t.integer  "runner_id"
    t.integer  "projected_race_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "full_name",         limit: 255
  end

  add_index "projected_results", ["projected_race_id"], name: "index_projected_results_on_projected_race_id", using: :btree
  add_index "projected_results", ["runner_id"], name: "index_projected_results_on_runner_id", using: :btree

  create_table "races", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.date     "date"
    t.float    "distance"
    t.integer  "temperature"
    t.integer  "humidity"
    t.string   "date_and_time",    limit: 255
    t.string   "location",         limit: 255
    t.string   "weather",          limit: 255
    t.string   "sponsor",          limit: 255
    t.boolean  "club_points",                  default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug",             limit: 255
    t.hstore   "men_results",                                  array: true
    t.hstore   "women_results",                                array: true
    t.hstore   "men_40_results",                               array: true
    t.hstore   "women_40_results",                             array: true
    t.hstore   "men_50_results",                               array: true
    t.hstore   "women_50_results",                             array: true
    t.hstore   "men_60_results",                               array: true
    t.hstore   "women_60_results",                             array: true
  end

  add_index "races", ["slug"], name: "index_races_on_slug", unique: true, using: :btree

  create_table "results", force: :cascade do |t|
    t.string   "last_name",       limit: 255
    t.string   "first_name",      limit: 255
    t.string   "sex",             limit: 255
    t.integer  "age"
    t.integer  "bib"
    t.string   "team",            limit: 255
    t.string   "city",            limit: 255
    t.string   "state",           limit: 255
    t.string   "country",         limit: 255
    t.integer  "overall_place"
    t.integer  "gender_place"
    t.integer  "age_place"
    t.string   "net_time",        limit: 255
    t.string   "finish_time",     limit: 255
    t.string   "gun_time",        limit: 255
    t.string   "pace_per_mile",   limit: 255
    t.string   "ag_time",         limit: 255
    t.integer  "ag_gender_place"
    t.float    "ag_percent"
    t.integer  "runner_id"
    t.integer  "race_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.date     "date"
    t.float    "distance"
    t.string   "split_5km"
    t.string   "split_10km"
    t.string   "split_15km"
    t.string   "split_20km"
    t.string   "split_25km"
    t.string   "split_30km"
    t.string   "split_40km"
    t.string   "split_131m"
    t.string   "residence"
    t.string   "split_35km"
  end

  add_index "results", ["race_id"], name: "index_results_on_race_id", using: :btree
  add_index "results", ["runner_id"], name: "index_results_on_runner_id", using: :btree

  create_table "runners", force: :cascade do |t|
    t.string  "first_name", limit: 255
    t.string  "last_name",  limit: 255
    t.integer "birth_year"
    t.string  "team",       limit: 255
    t.string  "sex",        limit: 255
    t.string  "slug",       limit: 255
    t.string  "full_name",  limit: 255
    t.string  "city",       limit: 255
    t.string  "state",      limit: 255
    t.string  "country",    limit: 255
  end

  add_index "runners", ["slug"], name: "index_runners_on_slug", unique: true, using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "slug",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "teams", ["slug"], name: "index_teams_on_slug", unique: true, using: :btree

end
