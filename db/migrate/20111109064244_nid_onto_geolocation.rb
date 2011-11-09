class NidOntoGeolocation < ActiveRecord::Migration
  def up
    add_column :geolocations, :nid, :string
  end

  def down
    remove_column :geolocations, :nid
  end
end
