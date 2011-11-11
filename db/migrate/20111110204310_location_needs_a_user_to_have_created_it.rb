class LocationNeedsAUserToHaveCreatedIt < ActiveRecord::Migration
  def up
    add_column :locations, :creator, :string
  end

  def down
    remove_column :locations, :creator
  end
end
