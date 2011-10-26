class RenameStuffsInTheRecommendationsTable < ActiveRecord::Migration
  def up
    remove_column :recommendations, :to_followers
    rename_column :recommendations, :lon, :lng
    change_column :recommendations, :twitter, :boolean, :null => true
    change_column :recommendations, :facebook, :boolean, :null => true
    change_column :recommendations, :new, :boolean, :default => true, :null => true
    change_column :recommendations, :is_valid, :boolean, :default => true, :null => true
  end

  def down
    add_column    :recommendations, :to_followers, :boolean,  :default => true,  :null => false
    rename_column :recommendations, :lng, :lnon
    change_column :recommendations, :twitter, :boolean, :null => false
    change_column :recommendations, :facebook, :boolean, :null => false
    change_column :recommendations, :new, :boolean, :default => true, :null => false
    change_column :recommendations, :is_valid, :boolean, :default => true, :null => false
  end
end
