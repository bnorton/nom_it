class ChangeToUserToToUserId < ActiveRecord::Migration
  def up
    rename_column :followers, :to_user, :to_user_id
  end

  def down
    rename_column :followers, :to_user_id, :to_user
  end
end
