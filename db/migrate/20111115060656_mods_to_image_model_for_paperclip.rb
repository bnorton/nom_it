class ModsToImageModelForPaperclip < ActiveRecord::Migration
  def up
    create_table "images", :force => true do |t|
      t.datetime "created_at"
      t.string   "image_file_name"
      t.string   "image_content_type"
      t.string   "image_file_size"
      t.datetime "image_updated_at"
      t.string   "nid"
      t.string   "user_nid"
      t.string   "location_nid"
    end
  end

  def down
    drop_table :images
  end
end
