class ChangeTo_nidFromId < ActiveRecord::Migration
  def up
    rename_column :followers, :user_id, :user_nid
    rename_column :followers, :to_user_id, :to_user_nid
  end

  def down
    rename_column :followers, :user_nid, :user_id
    rename_column :followers, :to_user_nid, :to_user_id
  end
end
