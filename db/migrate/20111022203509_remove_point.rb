class RemovePoint < ActiveRecord::Migration
  def up
    remove_column :geolocations, :point
  end

  def down
    add_column :geolocations, :point, :integer
  end
end
