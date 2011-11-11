class Rename_idTo_nid < ActiveRecord::Migration
  def up
    rename_column :locations, :revision_id, :revision_nid
    rename_column :locations, :metadata_id, :metadata_nid
    rename_column :recommendations, :user_id, :user_nid
  end

  def down
    rename_column :locations, :revision_nid, :revision_id
    rename_column :locations, :metadata_nid, :metadata_id
    rename_column :recommendations, :user_nid, :user_id

  end
end
