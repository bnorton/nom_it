class AddUnmatchedAndTraendingForGeolocation < ActiveRecord::Migration
  def up
    add_column :geolocations, :trending, :integer
    add_column :locations, :fsq_ignore, :boolean
  end

  def down
    remove_column :geolocations, :trending
    remove_column :locations, :fsq_ignore
  end
end
