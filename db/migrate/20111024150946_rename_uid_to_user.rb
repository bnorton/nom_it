class RenameUidToUser < ActiveRecord::Migration
  def up
    rename_column :recommendations, :uid, :user
  end

  def down
    rename_column :recommendations, :user, :uid
  end
end
