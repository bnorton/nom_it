class EditToMakeUserCity < ActiveRecord::Migration
  def up
    rename_column :followers, :from_city, :user_city
  end

  def down
    rename_column :followers, :user_city, :from_city
  end
end
