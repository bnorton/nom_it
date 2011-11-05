class RemoveNidsThatArentNeeded < ActiveRecord::Migration
  def up
    remove_column :followers, :nid
    remove_column :geolocations, :nid
    remove_column :revisions, :nid
    remove_column :statistics, :nid
  end

  def down
    add_column :followers, :nid, :string
    add_column :geolocations, :nid, :string
    add_column :revisions, :nid, :string
    add_column :statistics, :nid, :string
  end
end
