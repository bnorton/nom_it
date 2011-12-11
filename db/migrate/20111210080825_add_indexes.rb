class AddIndexes < ActiveRecord::Migration
  def up
    add_index :geolocations, :primary
    add_index :geolocations, :secondary
    add_index :geolocations, :rank_value
    add_index :geolocations, :trending
    add_index :geolocations, :location_nid
    add_index :geolocations, :cost
    
    add_index :images, :image_nid
    add_index :images, :user_nid
    add_index :images, :location_nid
    
    add_index :locations, :location_nid
    add_index :locations, :name
    
    add_index :recommendations, :recommendation_nid
    add_index :recommendations, :user_nid
    add_index :recommendations, :location_nid
    
    add_index :users, :user_nid
    
    remove_index :users, :name => :users_token_email
    remove_index :users, :name => :users_twitter
  end

  def down
    remove_index :geolocations, :primary
    remove_index :geolocations, :secondary
    remove_index :geolocations, :rank_value
    remove_index :geolocations, :trending
    remove_index :geolocations, :location_nid
    remove_index :geolocations, :cost
    
    remove_index :images, :image_nid
    remove_index :images, :user_nid
    remove_index :images, :location_nid
    
    remove_index :locations, :location_nid
    remove_index :locations, :name
    
    remove_index :recommendations, :recommendation_nid
    remove_index :recommendations, :user_nid
    remove_index :recommendations, :location_nid
    
    remove_index :users, :user_nid
    
    add_index :users, :name => :users_token_email
    
    add_index :users, :name => :users_twitter
  end
end
