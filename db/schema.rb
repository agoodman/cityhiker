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

ActiveRecord::Schema.define(version: 20171030022414) do

  create_table "delayed_jobs", force: :cascade do |t|
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

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "elevation_request_segments", force: :cascade do |t|
    t.integer  "elevation_request_id"
    t.integer  "index"
    t.integer  "way_id"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "elevation_requests", force: :cascade do |t|
    t.text     "encoded_polyline"
    t.string   "index_map"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  create_table "grid_requests", force: :cascade do |t|
    t.integer  "min_lat"
    t.integer  "min_lng"
    t.integer  "max_lat"
    t.integer  "max_lng"
    t.string   "url"
    t.time     "completed_at"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.integer  "sector_id"
  end

  add_index "grid_requests", ["sector_id"], name: "index_grid_requests_on_sector_id"

  create_table "open_street_map_nodes", force: :cascade do |t|
    t.string   "ref"
    t.float    "lat"
    t.float    "lng"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "open_street_map_nodes", ["ref"], name: "index_open_street_map_nodes_on_ref"

  create_table "open_street_map_ways", force: :cascade do |t|
    t.string   "ref"
    t.string   "nodes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "open_street_map_ways", ["ref"], name: "index_open_street_map_ways_on_ref"

  create_table "road_segments", force: :cascade do |t|
    t.float    "start_lat"
    t.float    "start_lng"
    t.float    "end_lat"
    t.float    "end_lng"
    t.float    "start_alt"
    t.float    "end_alt"
    t.float    "percent_grade"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.string   "hecto_key",     limit: 10
    t.string   "kilo_key",      limit: 10
  end

  add_index "road_segments", ["hecto_key"], name: "index_road_segments_on_hecto_key"
  add_index "road_segments", ["kilo_key"], name: "index_road_segments_on_kilo_key"

  create_table "sectors", force: :cascade do |t|
    t.integer  "scale_key"
    t.string   "cell_key"
    t.integer  "state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "sectors", ["scale_key", "cell_key"], name: "index_sectors_on_scale_key_and_cell_key"
  add_index "sectors", ["scale_key", "state"], name: "index_sectors_on_scale_key_and_state"
  add_index "sectors", ["scale_key"], name: "index_sectors_on_scale_key"
  add_index "sectors", ["state"], name: "index_sectors_on_state"

end
