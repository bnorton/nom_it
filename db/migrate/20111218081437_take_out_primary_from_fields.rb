class TakeOutPrimaryFromFields < ActiveRecord::Migration
  def up
    rename_column :locations, :primary, :primary_category
    rename_column :locations, :secondary, :secondary_category

    rename_column :geolocations, :primary, :primary_category
    rename_column :geolocations, :secondary, :secondary_category
  end

  def down
    rename_column :locations, :primary_category, :primary
    rename_column :locations, :secondary_category, :secondary

    rename_column :geolocations, :primary_category, :primary
    rename_column :geolocations, :secondary_category, :secondary
  end
end
