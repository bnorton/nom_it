class RemoveImageTable < ActiveRecord::Migration
  def up
    drop_table :images
  end

  def down
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
      t.string   "nid"
    end

    add_index "images", ["location_id", "link"], :name => "images_link"
  end
end
