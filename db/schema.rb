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

ActiveRecord::Schema.define(version: 2021_02_12_043243) do

  create_table "accessories", force: :cascade do |t|
    t.string "product_id"
    t.string "name"
    t.string "accessory_type"
    t.string "description"
    t.string "unit_price"
  end

  create_table "accounts", force: :cascade do |t|
    t.integer "user_id"
    t.string "name"
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "joins", force: :cascade do |t|
    t.integer "model_id"
    t.integer "accessory_id"
    t.index ["accessory_id"], name: "index_joins_on_accessory_id"
    t.index ["model_id"], name: "index_joins_on_model_id"
  end

  create_table "models", force: :cascade do |t|
    t.string "name"
    t.float "price"
  end

  create_table "proposals", force: :cascade do |t|
    t.date "proposal_date"
    t.integer "account_id"
    t.index ["account_id"], name: "index_proposals_on_account_id"
  end

  create_table "units", force: :cascade do |t|
    t.integer "model_id"
    t.integer "proposal_id"
    t.index ["model_id"], name: "index_units_on_model_id"
    t.index ["proposal_id"], name: "index_units_on_proposal_id"
  end

end
