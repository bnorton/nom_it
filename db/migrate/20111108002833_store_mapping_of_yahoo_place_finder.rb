class StoreMappingOfYahooPlaceFinder < ActiveRecord::Migration
  def up
    add_column :locations, :yid, :string
    add_column :locations, :woeid, :string
  end

  def down
    remove_column :locations, :yid
    remove_column :locations, :woeid
  end
end
