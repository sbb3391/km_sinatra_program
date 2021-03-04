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

ActiveRecord::Schema.define(version: 2021_03_04_174133) do

  create_table "accounts", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "images", force: :cascade do |t|
    t.string "image"
    t.string "caption"
  end

  create_table "line_items", force: :cascade do |t|
    t.integer "proposal_id"
    t.integer "product_id"
    t.integer "quantity"
    t.decimal "extended_price"
    t.decimal "color_cpi"
    t.decimal "mono_cpi"
    t.integer "service_lock_years"
    t.string "one_click_maximum"
    t.string "image"
    t.index ["product_id"], name: "index_line_items_on_product_id"
    t.index ["proposal_id"], name: "index_line_items_on_proposal_id"
  end

  create_table "pricing_options", force: :cascade do |t|
    t.string "name"
    t.float "lease_rate_factor"
  end

# Could not dump table "products" because of following StandardError
#   Unknown type 'decmial' for column 'price'

  create_table "proposal_pricing_options", force: :cascade do |t|
    t.integer "pricing_option_id"
    t.integer "proposal_id"
    t.index ["pricing_option_id"], name: "index_proposal_pricing_options_on_pricing_option_id"
    t.index ["proposal_id"], name: "index_proposal_pricing_options_on_proposal_id"
  end

  create_table "proposals", force: :cascade do |t|
    t.datetime "created_date"
    t.integer "account_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "show_summary"
    t.string "name"
    t.index ["account_id"], name: "index_proposals_on_account_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "password_digest"
  end

end
