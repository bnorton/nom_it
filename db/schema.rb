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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20111026033410) do

  create_table "followers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",                       :null => false
    t.string   "user_name"
    t.string   "user_city"
    t.integer  "to_user",                       :null => false
    t.string   "to_name"
    t.boolean  "approved",   :default => true,  :null => false
    t.boolean  "undirected", :default => false, :null => false
    t.binary   "schemaless"
  end

  add_index "followers", ["to_user", "user_id"], :name => "followers_to_from", :unique => true
  add_index "followers", ["user_id", "to_user"], :name => "followers_from_to", :unique => true

  create_table "geolocations", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_id",                  :null => false
    t.float    "lat",         :default => 0.0
    t.float    "lng",         :default => 0.0
  end

  add_index "geolocations", ["lat", "lng"], :name => "geolocations_lat_long"
  add_index "geolocations", ["lng", "lat"], :name => "geolocations_long_lat"

  create_table "images", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "link"
    t.integer  "uid",                            :null => false
    t.integer  "location_id",                    :null => false
    t.string   "name"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.text     "metadata"
    t.string   "description"
    t.boolean  "is_valid",    :default => false, :null => false
    t.binary   "schemaless"
  end

  add_index "images", ["location_id", "link"], :name => "images_link"

  create_table "locations", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.integer  "revision",                                     :null => false
    t.string   "fsq_name"
    t.string   "fsq_id"
    t.string   "gowalla_url"
    t.string   "gowalla_name"
    t.string   "address"
    t.string   "cross_street"
    t.string   "street"
    t.string   "street2"
    t.string   "city"
    t.string   "state"
    t.string   "area_code",    :limit => 7
    t.string   "country"
    t.text     "json_encode"
    t.boolean  "is_new",                    :default => false, :null => false
    t.string   "code"
    t.binary   "schemaless"
    t.string   "primary"
    t.string   "secondary"
  end

  add_index "locations", ["code"], :name => "locations_code"
  add_index "locations", ["id", "revision"], :name => "locations_id_revision", :unique => true
  add_index "locations", ["name", "address"], :name => "locations_name_address", :unique => true

  create_table "rankings", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_id",              :null => false
    t.integer  "user_id",                  :null => false
    t.integer  "value",       :limit => 8
    t.binary   "schemaless"
  end

  add_index "rankings", ["location_id", "user_id"], :name => "rankings_location_uid", :unique => true
  add_index "rankings", ["user_id", "location_id"], :name => "rankings_uid_location"

  create_table "recommendations", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",                          :null => false
    t.string   "token"
    t.integer  "location_id",                      :null => false
    t.string   "location_name"
    t.string   "location_city"
    t.string   "title"
    t.text     "text"
    t.boolean  "facebook",      :default => false
    t.boolean  "twitter",       :default => false
    t.float    "lat"
    t.float    "lng"
    t.boolean  "new",           :default => true
    t.binary   "schemaless"
    t.boolean  "is_valid",      :default => true
    t.string   "image"
    t.string   "user_name"
  end

  add_index "recommendations", ["location_id", "new"], :name => "recommendations_location_new"
  add_index "recommendations", ["user_id", "new"], :name => "recommendations_uid_new"

  create_table "revisions", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_id",                           :null => false
    t.string   "primary_category"
    t.string   "secondary_category"
    t.integer  "user_id",                               :null => false
    t.string   "title"
    t.text     "text"
    t.text     "best"
    t.text     "meh"
    t.string   "comment"
    t.boolean  "deleted",            :default => false, :null => false
    t.string   "hours"
    t.string   "phone"
    t.string   "twitter"
    t.string   "neighborhoods"
    t.string   "url"
    t.integer  "walkability"
    t.binary   "schemaless"
  end

  add_index "revisions", ["location_id"], :name => "revisions_location"
  add_index "revisions", ["primary_category"], :name => "revisions_primary_category"
  add_index "revisions", ["secondary_category"], :name => "revisions_secondary_category"

  create_table "statistics", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_id",                                       :null => false
    t.integer  "recommendations"
    t.integer  "recommends_count"
    t.integer  "rrr"
    t.integer  "rrt"
    t.integer  "quarter"
    t.integer  "half",                               :default => 0, :null => false
    t.integer  "mile",                               :default => 0, :null => false
    t.integer  "two"
    t.integer  "quarter_total"
    t.integer  "halmile_total"
    t.integer  "mile_total"
    t.integer  "two_mile_total"
    t.date     "established"
    t.integer  "yelp_reviews"
    t.float    "yelp_rating"
    t.integer  "opentable_reviews"
    t.float    "opentable_rating"
    t.integer  "gowalla_checkins"
    t.integer  "gowalla_users"
    t.integer  "fsq_checkins"
    t.integer  "fsq_users"
    t.integer  "fsq_tips"
    t.integer  "tweets"
    t.integer  "nom_facebook_posts"
    t.integer  "view_count"
    t.string   "json_encode",        :limit => 1022
    t.binary   "schemaless"
  end

  add_index "statistics", ["location_id"], :name => "statistics_location", :unique => true
  add_index "statistics", ["rrr", "rrt"], :name => "statistics_rrr_rrt"

  create_table "tags", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "location_id", :null => false
    t.string   "text"
  end

  add_index "tags", ["text", "location_id"], :name => "sc_tags_bId", :unique => true
  add_index "tags", ["text", "location_id"], :name => "text_location"

  create_table "users", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "name"
    t.string   "facebook"
    t.string   "twitter"
    t.string   "google"
    t.string   "last_seen"
    t.string   "udid"
    t.string   "url"
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.string   "password",                       :default => ""
    t.string   "salt"
    t.string   "session_id"
    t.binary   "newpassword",    :limit => 255
    t.datetime "newpass_time"
    t.string   "email"
    t.string   "phone"
    t.string   "screen_name"
    t.text     "description"
    t.datetime "authenticated"
    t.string   "token"
    t.date     "token_expires"
    t.string   "referral_code",  :limit => 32
    t.string   "referred_by",    :limit => 32
    t.binary   "schemaless"
    t.string   "json_encode",    :limit => 1022
    t.integer  "follower_count"
    t.string   "oauth_token"
    t.string   "oauth_secret"
    t.binary   "facebook_hash"
    t.binary   "twitter_hash"
    t.boolean  "has_joined",                     :default => true
  end

  add_index "users", ["email"], :name => "users_email", :unique => true
  add_index "users", ["facebook"], :name => "users_facebook", :unique => true
  add_index "users", ["screen_name"], :name => "users_screen_name", :unique => true
  add_index "users", ["token", "email"], :name => "users_token_email"
  add_index "users", ["twitter"], :name => "users_twitter", :unique => true

end
