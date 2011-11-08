class GeolocationGetsCategoriesAndCost < ActiveRecord::Migration
  def up
    add_column :geolocations, :cost, :integer
    add_column :geolocations, :primary, :string
    add_column :geolocations, :secondary, :string
  end

  def down
    remove_column :geolocations, :cost
    remove_column :geolocations, :primary
    remove_column :geolocations, :secondary
  end
end
