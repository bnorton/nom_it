class AddingNomRank < ActiveRecord::Migration
  def up
    add_column :locations, :rank, :string
    add_column :geolocations, :rank, :string
  end

  def down
    remove_column :locations, :rank
    remove_column :geolocations, :rank
  end
end
