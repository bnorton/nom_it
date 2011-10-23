class RemoveRequsitesOnUsers < ActiveRecord::Migration
  def up
    change_column :users, :salt, :string, :null => true
    change_column :users, :password, :string, :null => true
    change_column :users, :email, :string, :null => true
  end

  def down
    change_column :users, :salt, :string, :null => false
    change_column :users, :password, :string, :null => false
    change_column :users, :email, :string, :null => false
  end
end
