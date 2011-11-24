class ChangeToAuthToken < ActiveRecord::Migration
  def up
    rename_column :users, :session_id, :auth_token
    add_column :users, :image_nid, :string
    rename_column :recommendations, :image, :image_nid
  end

  def down
    rename_column :users, :auth_token, :session_id
    remove_column :users, :image_nid
    rename_column :recommendations, :image_nid, :image_nid
  end
end
