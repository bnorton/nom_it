class SwitchToActivitySyntax < ActiveRecord::Migration
  def up
    remove_index :recommendations, :name => :recommendations_location_new
    remove_index :recommendations, :name => :index_recommendations_on_recommendation_nid
    remove_index :recommendations, :name => :recommendations_uid_new

    remove_index :users, :name => :index_users_on_user_nid

    remove_index :locations, :name => :index_locations_on_location_nid

    remove_column :recommendations, :location_name
    remove_column :recommendations, :location_city
    remove_column :recommendations, :new
    remove_column :recommendations, :user_name

  end

  def down
    add_column :recommendations, :location_name, :string
    add_column :recommendations, :location_city, :string
    add_column :recommendations, :new, :boolean
    add_column :recommendations, :user_name, :string
  end
end

  # create_table "recommendations", :force => true do |t|
  #   t.datetime "created_at"
  #   t.datetime "updated_at"
  #   t.string   "recommendation_nid"
  #   t.string   "user_nid",                              :null => false
  #   t.string   "user_name"
  #   t.string   "location_nid"
  #   t.string   "location_name"
  #   t.string   "location_city"
  #   t.string   "token"
  #   t.string   "title"
  #   t.text     "text"
  #   t.boolean  "facebook",           :default => false
  #   t.boolean  "twitter",            :default => false
  #   t.float    "lat"
  #   t.float    "lng"
  #   t.boolean  "new",                :default => true
  #   t.binary   "schemaless"
  #   t.boolean  "is_valid",           :default => true
  #   t.string   "image_nid"
  # end
