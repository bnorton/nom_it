class RemoveStatisticsTable < ActiveRecord::Migration
  def up
    drop_table :statistics
  end

  def down
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
  end
end
