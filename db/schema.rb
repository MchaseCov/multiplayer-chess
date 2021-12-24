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

ActiveRecord::Schema.define(version: 2021_12_24_180523) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "chats", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["game_id"], name: "index_chats_on_game_id"
  end

  create_table "games", force: :cascade do |t|
    t.bigint "white_player_id", null: false
    t.bigint "color_player_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "game_over", default: false
    t.boolean "turn", default: false
    t.bigint "winner_id"
    t.boolean "check", default: false
    t.integer "turns_count"
    t.bigint "draw_requestor_id"
    t.index ["color_player_id"], name: "index_games_on_color_player_id"
    t.index ["draw_requestor_id"], name: "index_games_on_draw_requestor_id"
    t.index ["white_player_id"], name: "index_games_on_white_player_id"
    t.index ["winner_id"], name: "index_games_on_winner_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "body"
    t.bigint "author_id", null: false
    t.bigint "chat_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_id"], name: "index_messages_on_author_id"
    t.index ["chat_id"], name: "index_messages_on_chat_id"
  end

  create_table "pieces", force: :cascade do |t|
    t.string "type"
    t.boolean "color"
    t.boolean "taken", default: false
    t.boolean "has_moved", default: false
    t.bigint "game_id", null: false
    t.bigint "square_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.index ["color"], name: "index_pieces_on_color"
    t.index ["game_id"], name: "index_pieces_on_game_id"
    t.index ["square_id"], name: "index_pieces_on_square_id"
    t.index ["taken"], name: "index_pieces_on_taken"
    t.index ["type"], name: "index_pieces_on_type"
    t.index ["user_id"], name: "index_pieces_on_user_id"
  end

  create_table "squares", force: :cascade do |t|
    t.integer "row"
    t.integer "column"
    t.bigint "game_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "urgent", default: false
    t.index ["column"], name: "index_squares_on_column"
    t.index ["game_id"], name: "index_squares_on_game_id"
    t.index ["row"], name: "index_squares_on_row"
    t.index ["urgent"], name: "index_squares_on_urgent"
  end

  create_table "turns", force: :cascade do |t|
    t.bigint "game_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "start_piece_id", null: false
    t.bigint "end_piece_id"
    t.bigint "start_square_id", null: false
    t.bigint "end_square_id", null: false
    t.index ["end_piece_id"], name: "index_turns_on_end_piece_id"
    t.index ["end_square_id"], name: "index_turns_on_end_square_id"
    t.index ["game_id"], name: "index_turns_on_game_id"
    t.index ["start_piece_id"], name: "index_turns_on_start_piece_id"
    t.index ["start_square_id"], name: "index_turns_on_start_square_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: 6
    t.datetime "remember_created_at", precision: 6
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "chats", "games"
  add_foreign_key "games", "users", column: "color_player_id"
  add_foreign_key "games", "users", column: "draw_requestor_id"
  add_foreign_key "games", "users", column: "white_player_id"
  add_foreign_key "games", "users", column: "winner_id"
  add_foreign_key "messages", "chats"
  add_foreign_key "messages", "users", column: "author_id"
  add_foreign_key "pieces", "games"
  add_foreign_key "pieces", "squares"
  add_foreign_key "pieces", "users"
  add_foreign_key "squares", "games"
  add_foreign_key "turns", "games"
  add_foreign_key "turns", "pieces", column: "end_piece_id"
  add_foreign_key "turns", "pieces", column: "start_piece_id"
  add_foreign_key "turns", "squares", column: "end_square_id"
  add_foreign_key "turns", "squares", column: "start_square_id"
end
