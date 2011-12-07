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

ActiveRecord::Schema.define(:version => 20111206203640) do

  create_table "followers", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_nid",                       :null => false
    t.string   "user_name"
    t.string   "user_city"
    t.string   "to_user_nid",                    :null => false
    t.string   "to_name"
    t.boolean  "approved",    :default => true,  :null => false
    t.boolean  "undirected",  :default => false, :null => false
    t.binary   "schemaless"
  end

  add_index "followers", ["to_user_nid", "user_nid"], :name => "followers_to_from", :unique => true
  add_index "followers", ["user_nid", "to_user_nid"], :name => "followers_from_to", :unique => true

  create_table "geolocations", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.float    "lat",          :default => 0.0
    t.float    "lng",          :default => 0.0
    t.string   "cost"
    t.string   "primary"
    t.string   "secondary"
    t.string   "location_nid"
    t.string   "rank"
    t.integer  "rank_value"
    t.integer  "trending"
  end

  add_index "geolocations", ["lat", "lng"], :name => "geolocations_lat_long"
  add_index "geolocations", ["lng", "lat"], :name => "geolocations_long_lat"

  create_table "images", :force => true do |t|
    t.datetime "created_at"
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.string   "image_file_size"
    t.datetime "image_updated_at"
    t.string   "image_nid"
    t.string   "user_nid"
    t.string   "location_nid"
  end

  create_table "locations", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "location_nid"
    t.string   "name"
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
    t.string   "area_code"
    t.string   "country"
    t.text     "json_encode"
    t.boolean  "is_new",        :default => false, :null => false
    t.string   "code"
    t.binary   "schemaless"
    t.string   "primary"
    t.string   "secondary"
    t.string   "location_hash"
    t.string   "yid"
    t.string   "woeid"
    t.string   "neighborhoods"
    t.string   "url"
    t.string   "twitter"
    t.string   "facebook"
    t.string   "phone"
    t.string   "cost"
    t.string   "timeofday"
    t.string   "revision_nid"
    t.string   "metadata_nid"
    t.string   "creator"
    t.string   "rank"
    t.integer  "rank_value"
  end

  add_index "locations", ["location_nid"], :name => "index_locations_on_nid", :unique => true

  create_table "recommendations", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "recommendation_nid"
    t.string   "user_nid",                              :null => false
    t.string   "user_name"
    t.string   "location_nid"
    t.string   "location_name"
    t.string   "location_city"
    t.string   "token"
    t.string   "title"
    t.text     "text"
    t.boolean  "facebook",           :default => false
    t.boolean  "twitter",            :default => false
    t.float    "lat"
    t.float    "lng"
    t.boolean  "new",                :default => true
    t.binary   "schemaless"
    t.boolean  "is_valid",           :default => true
    t.string   "image_nid"
  end

  add_index "recommendations", ["new"], :name => "recommendations_location_new"
  add_index "recommendations", ["recommendation_nid"], :name => "index_recommendations_on_nid", :unique => true
  add_index "recommendations", ["user_nid", "new"], :name => "recommendations_uid_new"

  create_table "users", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_nid"
    t.string   "name"
    t.string   "screen_name"
    t.string   "email"
    t.string   "phone"
    t.string   "facebook"
    t.string   "twitter"
    t.string   "google"
    t.string   "last_seen"
    t.string   "udid"
    t.string   "url"
    t.string   "image_url"
    t.string   "street"
    t.string   "city"
    t.string   "state"
    t.string   "zip"
    t.string   "country"
    t.string   "password",                        :default => ""
    t.string   "salt"
    t.string   "auth_token"
    t.binary   "newpassword",     :limit => 255
    t.datetime "newpass_time"
    t.text     "description"
    t.datetime "authenticated"
    t.string   "token"
    t.date     "token_expires"
    t.string   "referral_code",   :limit => 32
    t.string   "referred_by",     :limit => 32
    t.string   "json_encode",     :limit => 1022
    t.integer  "follower_count"
    t.string   "oauth_token"
    t.string   "oauth_secret"
    t.binary   "facebook_hash"
    t.binary   "twitter_hash"
    t.boolean  "has_joined",                      :default => true
    t.binary   "schemaless"
    t.string   "image_nid"
    t.string   "fb_access_token"
  end

  add_index "users", ["email"], :name => "users_email", :unique => true
  add_index "users", ["facebook"], :name => "users_facebook", :unique => true
  add_index "users", ["screen_name"], :name => "users_screen_name", :unique => true
  add_index "users", ["token", "email"], :name => "users_token_email"
  add_index "users", ["twitter"], :name => "users_twitter", :unique => true
  add_index "users", ["user_nid"], :name => "index_users_on_nid", :unique => true

end
