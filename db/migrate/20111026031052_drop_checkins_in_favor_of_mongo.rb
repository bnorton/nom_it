class DropCheckinsInFavorOfMongo < ActiveRecord::Migration
  def up
    drop_table :checkins
  end

  def down
    create_table "checkins", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "location",                      :null => false
      t.integer  "uid",                           :null => false
      t.string   "title"
      t.string   "text"
      t.string   "image"
      t.boolean  "private",    :default => false, :null => false
      t.binary   "schemaless"
    end
  end
end
