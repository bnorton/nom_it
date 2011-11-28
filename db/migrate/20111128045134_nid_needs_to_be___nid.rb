class NidNeedsToBe_Nid < ActiveRecord::Migration
  def up
    rename_column :users, :nid, :user_nid
    rename_column :locations, :nid, :location_nid
    rename_column :images, :nid, :image_nid
    rename_column :recommendations, :nid, :recommendation_nid
  end

  def down
    rename_column :users, :user_nid, :nid
    rename_column :locations, :location_nid, :nid
    rename_column :images, :image_nid, :nid
    rename_column :recommendations, :recommendation_nid, :nid
  end
end
