class ModifyFollowersToHaveNid < ActiveRecord::Migration
  def up
    add_column :followers, :nid, :string
  end

  def down
    remove_column :followers, :nid
  end
end
