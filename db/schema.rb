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

ActiveRecord::Schema.define(version: 2019_07_29_114444) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "agents", force: :cascade do |t|
    t.string "name"
    t.string "category"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_agents_on_user_id"
  end

  create_table "bm_agents", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_bm_agents_on_user_id"
  end

  create_table "bm_secondary_needs", force: :cascade do |t|
    t.float "prevision"
    t.integer "period"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_bm_secondary_needs_on_user_id"
  end

  create_table "bm_secondary_results", force: :cascade do |t|
    t.string "bm_agent_name"
    t.string "bm_unit_name"
    t.integer "period"
    t.float "power"
    t.float "down_traded"
    t.float "power_down"
    t.float "up_traded"
    t.float "power_up"
    t.float "price"
    t.float "market_price"
    t.float "system_down_needs"
    t.float "system_up_needs"
    t.bigint "simulation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["simulation_id"], name: "index_bm_secondary_results_on_simulation_id"
  end

  create_table "bm_unit_offers", force: :cascade do |t|
    t.float "price"
    t.float "energy"
    t.integer "period"
    t.bigint "bm_unit_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "energy_down"
    t.index ["bm_unit_id"], name: "index_bm_unit_offers_on_bm_unit_id"
  end

  create_table "bm_units", force: :cascade do |t|
    t.string "fuel"
    t.string "category"
    t.bigint "bm_agent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["bm_agent_id"], name: "index_bm_units_on_bm_agent_id"
  end

  create_table "offers", force: :cascade do |t|
    t.float "energy"
    t.float "price"
    t.integer "period"
    t.bigint "agent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_offers_on_agent_id"
  end

  create_table "results", force: :cascade do |t|
    t.integer "period"
    t.float "power"
    t.float "traded_power"
    t.float "price"
    t.float "market_price"
    t.bigint "simulation_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "agent_name"
    t.index ["simulation_id"], name: "index_results_on_simulation_id"
  end

  create_table "simulations", force: :cascade do |t|
    t.datetime "date"
    t.string "market_type"
    t.string "pricing_mechanism"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_simulations_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "agents", "users"
  add_foreign_key "bm_agents", "users"
  add_foreign_key "bm_secondary_needs", "users"
  add_foreign_key "bm_secondary_results", "simulations"
  add_foreign_key "bm_unit_offers", "bm_units"
  add_foreign_key "bm_units", "bm_agents"
  add_foreign_key "offers", "agents"
  add_foreign_key "results", "simulations"
  add_foreign_key "simulations", "users"
end
