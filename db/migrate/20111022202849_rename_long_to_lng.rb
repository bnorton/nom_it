class RenameLongToLng < ActiveRecord::Migration
  def up
    rename_column :geolocations, :long, :lng
  end

  def down
    rename_column :geolocations, :lng, :long
  end
end
