class AddHashToLocation < ActiveRecord::Migration
  def up
    add_column :locations, :hash, :string
  end
  
  def down
    remove_column :locations, :hash
  end
end
