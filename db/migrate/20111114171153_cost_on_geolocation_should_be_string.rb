class CostOnGeolocationShouldBeString < ActiveRecord::Migration
  def up
    change_column :geolocations, :cost, :string
  end

  def down
    change_column :geolocations, :cost, :integer
  end
end
