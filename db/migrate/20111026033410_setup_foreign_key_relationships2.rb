class SetupForeignKeyRelationships2 < ActiveRecord::Migration
  def up
    rename_column :revisions, :location, :location_id
  end

  def down
    rename_column :revisions, :location_id, :location
  end
end
