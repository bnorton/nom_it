class DropSearchesInFavorOfMongo < ActiveRecord::Migration
  def up
    drop_table :searches
  end

  def down
    create_table "searches", :force => true do |t|
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "location",   :null => false
      t.string   "title"
      t.string   "address"
      t.string   "city"
      t.string   "tags"
      t.text     "text"
      t.binary   "schemaless"
    end
  end
end
