class AddHashStorageToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :facebook_hash, :blob
    add_column :users, :twitter_hash,  :blob
  end

  def self.down
    remove_column :users, :facebook_hash
    remove_column :users, :twitter_hash
  end
end
