class RankValueAsInteger < ActiveRecord::Migration
  def up
    add_column :locations, :rank_value, :integer
    add_column :geolocations, :rank_value, :integer
  end

  def down
    remove_column :locations, :rank_value
    remove_column :geolocations, :rank_value
  end
end
