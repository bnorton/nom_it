class RemoveRecommmeds < ActiveRecord::Migration
  def up
    drop_table :recommends
  end

  def down
    create_table "recommends", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "from"
      t.string   "from_name"
      t.integer  "to"
      t.string   "to_name"
      t.integer  "location",                        :null => false
      t.string   "location_name"
      t.string   "location_city"
      t.string   "title"
      t.string   "text"
      t.float    "lat",           :default => 0.0
      t.float    "long",          :default => 0.0
      t.binary   "schemaless"
      t.boolean  "is_valid",      :default => true, :null => false
    end
  
    add_index "recommends", ["from", "to"], :name => "recommendations_from_to"
    add_index "recommends", ["to", "from"], :name => "recommendations_to_from"
  end
end
