class RemoveaAllLocationsIds < ActiveRecord::Migration
  def up
    remove_column :recommendations, :location_id
    add_column :recommendations, :location_nid, :string
    
    remove_column :geolocations, :location_id
    add_column :geolocations, :location_nid, :string
  end

  def down
    add_column :recommendations, :location_id, :integer
    remove_column :recommendations, :location_nid
    
    add_column :geolocations, :location_id, :integer
    remove_column :geolocations, :location_nid
  end
end
