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

ActiveRecord::Schema.define(version: 20140121214139) do

  create_table "comparisons", force: true do |t|
    t.string   "name"
    t.text     "note"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "comparisons", ["user_id"], name: "index_comparisons_on_user_id"

  create_table "products", force: true do |t|
    t.string   "name"
    t.text     "url"
    t.integer  "comparison_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "ranking"
    t.string   "asin"
  end

  add_index "products", ["asin"], name: "index_products_on_asin"
  add_index "products", ["comparison_id"], name: "index_products_on_comparison_id"

  create_table "shared_tributes", force: true do |t|
    t.string   "name"
    t.float    "weight"
    t.integer  "comparison_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "shared_tributes", ["comparison_id"], name: "index_shared_tributes_on_comparison_id"

  create_table "tributes", force: true do |t|
    t.text     "name" #,          limit: 255
    t.float    "weight"
    t.integer  "product_id"
    t.integer  "comparison_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "value"
    t.float    "score"
    t.integer  "group"
    t.integer  "placement"
    t.string   "asin"
  end

  add_index "tributes", ["comparison_id"], name: "index_tributes_on_comparison_id"
  add_index "tributes", ["product_id"], name: "index_tributes_on_product_id"

  create_table "users", force: true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "password_digest"
    t.integer  "gender"
    t.integer  "zipcode"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
