class FbAccessTokenIntoUser < ActiveRecord::Migration
  def up
    add_column :users, :fb_access_token, :string
  end

  def down
    remove_column :users, :fb_access_token
  end
end
