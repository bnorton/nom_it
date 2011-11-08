class LocationsUpdateForDropOfRevisions < ActiveRecord::Migration
  def up
    add_column :locations, :metadata_id, :string
    add_column :locations, :neighborhoods, :string
    add_column :locations, :url, :string
    add_column :locations, :revision_id, :string
    add_column :locations, :twitter, :string
    add_column :locations, :facebook, :string
    add_column :locations, :phone, :string
    add_column :locations, :cost, :string
    add_column :locations, :timeofday, :string
    remove_column :locations, :revision
  end

  def down
    remove_column :locations, :metadata_id
    remove_column :locations, :neighborhoods
    remove_column :locations, :url
    remove_column :locations, :revision_id
    remove_column :locations, :twitter
    remove_column :locations, :facebook
    remove_column :locations, :phone
    remove_column :locations, :cost
    remove_column :locations, :timeofday
    add_column :locations, :revision, :integer
  end
end
