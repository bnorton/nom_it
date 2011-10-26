class SetupForeignKeyRelationships < ActiveRecord::Migration
  def up
    rename_column :followers,     :user,     :user_id
    rename_column :geolocations,  :location, :location_id
    rename_column :images,        :location, :location_id
    rename_column :images,        :uid,      :user_id
    rename_column :rankings,      :location, :location_id
    rename_column :rankings,      :uid,     :user_id
    rename_column :recommendations, :location, :location_id
    rename_column :recommendations, :user,     :user_id
    rename_column :revisions,     :uid,     :user_id
    rename_column :revisions,     :location, :location_id
    rename_column :statistics,    :location, :location_id
    rename_column :tags,          :location, :location_id
  end

  def down
    rename_column :followers,    :user_id,      :user
    rename_column :geolocations, :location_id,  :location
    rename_column :images,       :location_id,  :location
    rename_column :images,       :user_id,      :uid
    rename_column :rankings,     :location_id,  :location
    rename_column :rankings,     :user_id,      :uid
    rename_column :recommendations, :location_id, :location
    rename_column :recommendations, :user_id,     :user
    rename_column :revisions,    :location_id, :location
    rename_column :revisions,    :user_id,     :uid
    rename_column :statistics,   :location_id, :location
    rename_column :tags,         :location_id, :location
  end
end
