class RenameFollowerToTo < ActiveRecord::Migration
  def up
    rename_column :followers, :follower, :to
    rename_column :followers, :follower_name, :to_name
  end

  def down
    rename_column :followers, :to, :follower
    rename_column :followers, :to_name, :follower_name
  end
end
