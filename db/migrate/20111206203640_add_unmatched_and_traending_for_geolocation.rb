class AddUnmatchedAndTraendingForGeolocation < ActiveRecord::Migration
  def up
    add_column :geolocations, :trending, :integer
  end

  def down
    remove_column :geolocations, :trending
  end
end
