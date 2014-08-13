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

ActiveRecord::Schema.define(version: 20140813173813) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "races", force: true do |t|
    t.string   "name"
    t.date     "date"
    t.float    "distance"
    t.integer  "temperature"
    t.integer  "humidity"
    t.string   "date_and_time"
    t.string   "location"
    t.string   "weather"
    t.string   "sponsor"
    t.boolean  "club_points",   default: false
    t.string   "organization"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "results", force: true do |t|
    t.string   "last_name"
    t.string   "first_name"
    t.string   "sex"
    t.integer  "age"
    t.integer  "bib"
    t.string   "team"
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.integer  "overall_place"
    t.integer  "gender_place"
    t.integer  "age_place"
    t.string   "net_time"
    t.string   "finish_time"
    t.string   "gun_time"
    t.string   "pace_per_mile"
    t.string   "ag_time"
    t.integer  "ag_gender_place"
    t.float    "ag_percent"
    t.integer  "runner_id"
    t.integer  "race_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "results", ["race_id"], name: "index_results_on_race_id", using: :btree
  add_index "results", ["runner_id"], name: "index_results_on_runner_id", using: :btree

  create_table "runners", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "birth_year"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
