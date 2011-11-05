class AddUniqueToAllTablesWithMandatoryNid < ActiveRecord::Migration
  def up
    add_index :locations, [:nid], :unique => true
    add_index :recommendations, [:nid], :unique => true
    add_index :users, [:nid], :unique => true
  end
  
  def down
    remove_index :locations, [:nid]
    remove_index :recommendations, [:nid]
    remove_index :users, [:nid]
  end
end
