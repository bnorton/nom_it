class DropRankingsForMongo < ActiveRecord::Migration
  def up
    drop_table :rankings
    drop_table :tags
  end

  def down
    create_table "rankings", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "location_id",              :null => false
      t.integer  "user_id",                  :null => false
      t.integer  "value",       :limit => 8
      t.binary   "schemaless"
      t.string   "nid"
    end
    
    create_table "tags", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "location_id", :null => false
      t.string   "text"
      t.string   "nid"
    end
  end
end
