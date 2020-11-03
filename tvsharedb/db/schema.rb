# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_11_03_224104) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "awards", force: :cascade do |t|
    t.string "awardCatId"
    t.string "awardId"
    t.string "awardName"
    t.string "category"
    t.string "name"
    t.string "year"
    t.bigint "show_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "personId"
    t.boolean "won"
    t.index ["show_id"], name: "index_awards_on_show_id"
  end

  create_table "casts", force: :cascade do |t|
    t.string "billingOrder"
    t.string "characterName"
    t.string "name"
    t.string "nameId"
    t.string "personId"
    t.string "role"
    t.bigint "show_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["show_id"], name: "index_casts_on_show_id"
  end

  create_table "comments", force: :cascade do |t|
    t.string "text"
    t.string "hashtag"
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "show_id", null: false
    t.text "images", default: [], array: true
    t.integer "likes_count"
    t.integer "sub_comments_count"
    t.text "videos", default: [], array: true
    t.bigint "shares_count", default: 0
    t.index ["show_id"], name: "index_comments_on_show_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "crews", force: :cascade do |t|
    t.string "billingOrder"
    t.string "name"
    t.string "nameId"
    t.string "personId"
    t.string "role"
    t.bigint "show_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["show_id"], name: "index_crews_on_show_id"
  end

  create_table "keywords", force: :cascade do |t|
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "Character", default: [], array: true
    t.string "Mood", default: [], array: true
    t.string "Setting", default: [], array: true
    t.string "Subject", default: [], array: true
    t.string "Theme", default: [], array: true
    t.string "Time_Period", default: [], array: true
    t.bigint "show_id"
    t.index ["show_id"], name: "index_keywords_on_show_id"
  end

  create_table "likes", force: :cascade do |t|
    t.boolean "like"
    t.bigint "user_id", null: false
    t.bigint "comment_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "show_id"
    t.bigint "sub_comment_id"
    t.bigint "story_id"
    t.index ["comment_id"], name: "index_likes_on_comment_id"
    t.index ["show_id"], name: "index_likes_on_show_id"
    t.index ["sub_comment_id"], name: "index_likes_on_sub_comment_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "networks", force: :cascade do |t|
    t.string "name"
    t.string "display_name"
    t.boolean "streaming", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "station_id"
    t.index ["name"], name: "index_networks_on_name", unique: true
  end

  create_table "networks_shows", id: false, force: :cascade do |t|
    t.bigint "show_id"
    t.bigint "network_id"
    t.index ["network_id"], name: "index_networks_shows_on_network_id"
    t.index ["show_id", "network_id"], name: "index_networks_shows_on_show_id_and_network_id", unique: true
    t.index ["show_id"], name: "index_networks_shows_on_show_id"
  end

  create_table "preferred_images", force: :cascade do |t|
    t.string "category"
    t.string "height"
    t.string "primary"
    t.text "uri"
    t.string "width"
    t.bigint "show_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["show_id"], name: "index_preferred_images_on_show_id"
  end

  create_table "quality_ratings", force: :cascade do |t|
    t.string "ratingsBody"
    t.string "value"
    t.bigint "show_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["show_id"], name: "index_quality_ratings_on_show_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.string "body"
    t.string "code"
    t.bigint "show_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["show_id"], name: "index_ratings_on_show_id"
  end

  create_table "recommendations", force: :cascade do |t|
    t.string "rootId"
    t.string "title"
    t.string "tmsId"
    t.bigint "show_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["show_id"], name: "index_recommendations_on_show_id"
  end

  create_table "relationships", force: :cascade do |t|
    t.integer "follower_id", null: false
    t.integer "followed_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["followed_id"], name: "index_relationships_on_followed_id"
    t.index ["follower_id", "followed_id"], name: "index_relationships_on_follower_id_and_followed_id", unique: true
    t.index ["follower_id"], name: "index_relationships_on_follower_id"
  end

  create_table "shares", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "shareable_id", null: false
    t.string "shareable_type", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["shareable_id", "shareable_type"], name: "index_shares_on_shareable_id_and_shareable_type"
    t.index ["user_id"], name: "index_shares_on_user_id"
  end

  create_table "shows", force: :cascade do |t|
    t.string "descriptionLang"
    t.string "entityType"
    t.text "longDescription"
    t.text "officialUrl"
    t.string "origAirDate"
    t.string "releaseDate"
    t.integer "releaseYear"
    t.integer "rootId"
    t.string "runTime"
    t.string "seriesId"
    t.text "shortDescription"
    t.string "subType"
    t.string "title"
    t.string "titleLang"
    t.string "tmsId"
    t.integer "totalEpisodes"
    t.string "totalSeasons"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "advisories", default: [], array: true
    t.string "directors", default: [], array: true
    t.string "genres", default: [], array: true
    t.integer "original_streaming_network"
    t.string "original_streaming_network_id"
    t.string "preferred_image_uri"
    t.bigint "shares_count", default: 0
    t.string "episodeTitle"
    t.integer "episodeNum"
    t.integer "seasonNum"
    t.bigint "comments_count", default: 0
    t.bigint "likes_count", default: 0
    t.bigint "stories_count", default: 0
    t.datetime "imported_news_at"
    t.json "cast", default: [], array: true
    t.json "crew", default: [], array: true
    t.index ["imported_news_at"], name: "index_shows_on_imported_news_at"
    t.index ["original_streaming_network", "original_streaming_network_id"], name: "orignal_network_and_id", unique: true
    t.index ["original_streaming_network"], name: "index_shows_on_original_streaming_network"
    t.index ["rootId"], name: "index_shows_on_rootId"
    t.index ["tmsId"], name: "index_shows_on_tmsId", unique: true
  end

  create_table "stories", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.text "source"
    t.string "image_url"
    t.string "url", null: false
    t.datetime "published_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "show_id"
    t.bigint "likes_count"
    t.bigint "shares_count", default: 0
    t.bigint "story_source_id"
    t.index ["show_id"], name: "index_stories_on_show_id"
    t.index ["story_source_id"], name: "index_stories_on_story_source_id"
    t.index ["url"], name: "index_stories_on_url", unique: true
  end

  create_table "story_sources", force: :cascade do |t|
    t.string "domain", null: false
    t.string "image_url"
    t.boolean "iframe_enabled", default: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["domain"], name: "index_story_sources_on_domain", unique: true
  end

  create_table "sub_comments", force: :cascade do |t|
    t.string "text"
    t.string "hashtag"
    t.text "images", default: [], array: true
    t.bigint "comment_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "videos", default: [], array: true
    t.bigint "shares_count", default: 0
    t.index ["comment_id"], name: "index_sub_comments_on_comment_id"
    t.index ["user_id"], name: "index_sub_comments_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "email"
    t.string "password_digest"
    t.integer "zipcode"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "gender"
    t.string "cable_provider"
    t.string "birth_date"
    t.text "image"
    t.text "bio"
    t.string "city"
    t.string "phone_number"
    t.string "streaming_service"
    t.string "google_id"
    t.string "facebook_id"
    t.string "name"
    t.index ["facebook_id"], name: "index_users_on_facebook_id", unique: true
    t.index ["google_id"], name: "index_users_on_google_id", unique: true
  end

  add_foreign_key "awards", "shows"
  add_foreign_key "casts", "shows"
  add_foreign_key "comments", "shows"
  add_foreign_key "comments", "users"
  add_foreign_key "crews", "shows"
  add_foreign_key "keywords", "shows"
  add_foreign_key "likes", "comments"
  add_foreign_key "likes", "shows"
  add_foreign_key "likes", "sub_comments"
  add_foreign_key "likes", "users"
  add_foreign_key "preferred_images", "shows"
  add_foreign_key "quality_ratings", "shows"
  add_foreign_key "ratings", "shows"
  add_foreign_key "recommendations", "shows"
  add_foreign_key "sub_comments", "comments"
  add_foreign_key "sub_comments", "users"
end
