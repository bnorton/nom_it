class NidOntoGeolocation < ActiveRecord::Migration
  def up
    add_column :geolocations, :location_nid, :string
  end

  def down
    remove_column :geolocations, :location_nid
  end
end
