# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_14_135355) do
  create_table "bouquet_packagings", force: :cascade do |t|
    t.string "name"
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bouquet_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "bouquets", force: :cascade do |t|
    t.string "name"
    t.integer "bouquet_type_id", null: false
    t.integer "bouquet_packaging_id", null: false
    t.decimal "price"
    t.decimal "discount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bouquet_packaging_id"], name: "index_bouquets_on_bouquet_packaging_id"
    t.index ["bouquet_type_id"], name: "index_bouquets_on_bouquet_type_id"
  end

  create_table "flower_in_bouquets", force: :cascade do |t|
    t.integer "flower_id", null: false
    t.integer "bouquet_id", null: false
    t.integer "quantity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bouquet_id"], name: "index_flower_in_bouquets_on_bouquet_id"
    t.index ["flower_id"], name: "index_flower_in_bouquets_on_flower_id"
  end

  create_table "flower_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "flowers", force: :cascade do |t|
    t.string "name"
    t.integer "flower_type_id", null: false
    t.decimal "price"
    t.decimal "discount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flower_type_id"], name: "index_flowers_on_flower_type_id"
  end

  create_table "orders", force: :cascade do |t|
    t.decimal "price"
    t.string "payment_method"
    t.string "delivery_method"
    t.datetime "ready_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.string "status", default: "draft", null: false
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "product_in_orders", force: :cascade do |t|
    t.integer "order_id", null: false
    t.integer "product_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "quantity"
    t.index ["order_id"], name: "index_product_in_orders_on_order_id"
    t.index ["product_id"], name: "index_product_in_orders_on_product_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.decimal "price"
    t.string "productable_type", null: false
    t.integer "productable_id", null: false
    t.string "product_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["productable_type", "productable_id"], name: "index_products_on_productable"
  end

  create_table "reviews", force: :cascade do |t|
    t.integer "rating"
    t.text "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "toys", force: :cascade do |t|
    t.string "name"
    t.string "size"
    t.string "material"
    t.decimal "price"
    t.decimal "discount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vases", force: :cascade do |t|
    t.string "name"
    t.string "size"
    t.string "material"
    t.decimal "price"
    t.decimal "discount"
    t.decimal "diameter"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "bouquets", "bouquet_packagings"
  add_foreign_key "bouquets", "bouquet_types"
  add_foreign_key "flower_in_bouquets", "bouquets"
  add_foreign_key "flower_in_bouquets", "flowers"
  add_foreign_key "flowers", "flower_types"
  add_foreign_key "orders", "users"
  add_foreign_key "product_in_orders", "orders"
  add_foreign_key "product_in_orders", "products"
end
