class UserShouldJoinAddedToUser < ActiveRecord::Migration
  def up
    add_column :users, :has_joined, :boolean, :default => true
  end

  def down
    remove_column :users, :has_joined
  end
end
