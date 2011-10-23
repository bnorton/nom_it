class NameChangeToFollowerMeAndFromToMe < ActiveRecord::Migration
  def up
    rename_column :followers, :from, :user
    rename_column :followers, :from_name, :user_name
    rename_column :followers, :to, :follower
    rename_column :followers, :to_name, :follower_name
  end

  def down
    rename_column :followers, :user, :from
    rename_column :followers, :user_name, :from_name
    rename_column :followers, :follower, :to
    rename_column :followers, :follower_name, :to_name
  end
end
