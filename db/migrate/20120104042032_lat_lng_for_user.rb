class LatLngForUser < ActiveRecord::Migration
  def up
    add_column :users, :lat, :double
    add_column :users, :lng, :double
  end

  def down
    remove_column :users, :lat
    remove_column :users, :lng
  end
end
