class AddPrimaryAndSecondaryCategoryToLocations < ActiveRecord::Migration
  def up
    add_column :locations, :primary,   :string
    add_column :locations, :secondary, :string
  end
  
  def down
    remove_column :locations, :primary
    remove_column :locations, :secondary
  end
  
end
