class DropAnIndexThatDoesntMatter < ActiveRecord::Migration
  def up
    remove_index :locations, :name => "locations_code"
    remove_index :locations, :name => "locations_id_revision"
    remove_index :locations, :name => "locations_name_address"
  end

  def down
    add_index "locations", ["code"], :name => "locations_code"
    add_index "locations", ["id"], :name => "locations_id_revision", :unique => true
    add_index "locations", ["name", "address"], :name => "locations_name_address", :unique => true
  end
end
