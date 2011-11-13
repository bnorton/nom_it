class EnsureNidFieldsAreStrings < ActiveRecord::Migration
  def up
    change_column :followers, :user_nid, :string
    change_column :followers, :to_user_nid, :string
    change_column :recommendations, :user_nid, :string
  end
  
  def down
    change_column :followers, :user_nid, :integer
    change_column :followers, :to_user_nid, :integer
    change_column :recommendations, :user_nid, :integer
  end
end
