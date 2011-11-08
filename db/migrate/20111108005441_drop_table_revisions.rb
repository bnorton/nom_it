class DropTableRevisions < ActiveRecord::Migration
  def up
    drop_table :revisions
    add_column :locations, :neighborhoods, :string
    add_column :locations, :url, :string
    add_column :locations, :revision_id, :string
    add_column :locations, :twitter, :string
    add_column :locations, :facebook, :string
    add_column :locations, :phone, :string
    add_column :locations, :cost, :string
    add_column :locations, :timeofday, :string
    add_column :locations, :metadata_id, :string
    remove_column :locations, :revision
  end

  def down
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
    
  end
end
