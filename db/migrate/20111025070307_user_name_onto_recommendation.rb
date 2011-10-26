class UserNameOntoRecommendation < ActiveRecord::Migration
  def up
    add_column :recommendations, :user_name, :string
  end

  def down
    remove_column :recommendations, :user_name
  end
end
