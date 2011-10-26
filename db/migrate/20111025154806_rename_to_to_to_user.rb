class RenameToToToUser < ActiveRecord::Migration
  def up
    rename_column :followers, :to, :to_user
  end

  def down
    rename_column :followers, :to_user, :to
  end
end
